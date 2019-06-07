/**
 * 
 */
package com.broadridge.unicorn.aggService.margin.services;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.broadridge.unicorn.aggService.beans.MarginCalBean;
import com.broadridge.unicorn.aggService.beans.MarginCalRequestBean;
import com.broadridge.unicorn.aggService.beans.MarginCalResponseBean;
import com.broadridge.unicorn.aggService.beans.RateRequirementBean;
import com.broadridge.unicorn.aggService.beans.UnitRequirementBean;
import com.broadridge.unicorn.aggService.domain.Position;
import com.broadridge.unicorn.aggService.domain.StraddleStrategyDTO;

@Service("marginCalService")
public class MarginCalServiceImpl implements MarginCalService {

	private final Logger LOGGER = LoggerFactory.getLogger(this.getClass());
	/**
	 * 
	 */
	private static final long serialVersionUID = 2370418826650610247L;

	@Override
	public List<MarginCalResponseBean> getMarginCaluculation(MarginCalRequestBean marginCalRequestBean)
			throws SQLException {
		List<MarginCalResponseBean> marginCalResponse = new ArrayList<>();
		try {
			Connection conn = DBClient.getConnection();
			conn.setAutoCommit(false);
			Statement stmt = conn.createStatement();
			String date = marginCalRequestBean.getDate();
			List<String> accountIds = marginCalRequestBean.getAccounts();
			accountIds.parallelStream().forEach(accountid -> {
				try {
					double tradeDtBalance = getTradeDateBalance(conn, stmt, date, accountid);
					double marketValue = getMarkeValue(conn, stmt, date, accountid);
					double marketValuefromTrns = getMarkeValuefromTransaction(conn, stmt, date, accountid);
					// Equity Caluculations
					MarginCalResponseBean marginCalResponseBean = getMarginNumbers(accountid, tradeDtBalance,	marketValue, marketValuefromTrns);
					// Naked Caluculations- Determine the different strategies:
					double rate = 0;// SELECT category,multiplier FROM public.requirements where security_class='O'; Before this check if the security class is E or O  Get it from the database; SELECT category,multiplier FROM public.requirements
									// where security_class='O' ;
					//Get positions List
						List<Position> positionList= getPositions( conn, stmt,accountid) ;
						Position position=positionList.get(0);
						int positionsList=positionList.size();
						String securityClass=position.getSecurityClass();
					// Get the straddle eligibility
					Map<String,RateRequirementBean> rateRequirementsMap=null;
					if(securityClass !=null && securityClass.equalsIgnoreCase("O"))
					{
						rateRequirementsMap=getRatesRequirements(conn, stmt,accountid,date,securityClass);
						if(positionsList==2)
						{
							boolean isEligible=isItEligibleforStraddle( conn,  stmt, accountid);
							if(isEligible)
							{
								MarginCalBean marginCalBean= performStraddleCaluculation( conn,stmt,accountid,date,rateRequirementsMap);
								marginCalResponseBean.setMargin(marginCalBean);
							}
						}else if(positionsList == 1)
						{// Delele all the below lines except  performNakedStrategyCaluculation call
							MarginCalBean marginCalBean0= performNakedStrategyCaluculation(conn,  stmt, accountid, date,rateRequirementsMap);
							RateRequirementBean rateRequirementforNYSE= rateRequirementsMap.get("NYSE");
							RateRequirementBean rateRequirementforHouse= rateRequirementsMap.get("House");
							RateRequirementBean rateRequirementforMaint= rateRequirementsMap.get("Maint");
							double nyseUnit = getUnitRequirement(conn, stmt, date, accountid, rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
							double houseUnit = getUnitRequirement(conn, stmt, date, accountid, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
							double nyseUnitReq=nyseUnit * rateRequirementforNYSE.getOptfactor() * rateRequirementforNYSE.getQuantity();
							double houseUnitReq=houseUnit * rateRequirementforHouse.getOptfactor() * rateRequirementforHouse.getQuantity();
							LOGGER.info(String.format("nyseUnitReq  = [%s] ", nyseUnitReq));
							LOGGER.info(String.format("houseUnitReq = [%s] ", houseUnitReq));
							LOGGER.info(String.format("*****************************************************************"));
							marginCalResponseBean.getMargin().setNyseReq(nyseUnitReq);
							marginCalResponseBean.getMargin().setHouseReq(houseUnitReq);
							MarginCalBean marginCalBean1= performNakedStrategyCaluculation(conn,  stmt, accountid, date,rateRequirementsMap);
							
						}
					}
					marginCalResponse.add(marginCalResponseBean);

				} catch (SQLException e) {
				}
			});
		} catch (Exception e) {
		}
		LOGGER.info(String.format("*****************************************************************"));
		return marginCalResponse;
	}

	private MarginCalResponseBean getMarginNumbers(String accountId, double tradeDtBalance, double marketValue,
			double marketValuefromTrns) {
		LOGGER.info(String.format("*****************************************************************"));
		LOGGER.info(String.format("TradeDtBalance = [%s] MarketValue = [%s] ", tradeDtBalance, marketValue));
		LOGGER.info(String.format("MarketValuefromTrns = [%s] ", marketValuefromTrns));
		MarginCalResponseBean marginCalResponse = new MarginCalResponseBean();
		MarginCalBean maginCal = new MarginCalBean();
		double equity = marketValue - tradeDtBalance;
		double regT = equity - (double) (50 * marketValuefromTrns) / 100;
		double house = equity - (double) (30 * marketValue) / 100;
		double maintenance = equity - (double) (25 * marketValue) / 100;
		maginCal.setRegT(regT);
		maginCal.setHouse(house);
		maginCal.setMaintenance(maintenance);
		// -- Buying power calc
		double maintenanceExcess = (double) maintenance / 0.3;
		double regTexcess = regT * 2;
		LOGGER.info(String.format("MaintenanceExcess = [%s] RegTexcess = [%s] ", maintenance, regT));
		
		double buyingPower = (maintenanceExcess > regTexcess) ? regTexcess : maintenanceExcess;
		maginCal.setBuyPower(buyingPower);
		//
		marginCalResponse.setAccountNo(accountId);
		marginCalResponse.setMargin(maginCal);
		return marginCalResponse;
	}

	private double getTradeDateBalance(Connection conn, Statement stmt, String date, String accountId)
			throws SQLException {
		double tradeDtBalance = 0;
		String tradeDateBalanceSQL = "select TRUNC(bd.trade_date_balance,2) as trade_date_balance from balance b, balancedetail bd, account a  where b.balance_id=bd.balance_id and bd.balance_detail_date='"
				+ date + "' and a.\"AccountIdentifier\"='" + accountId + "' and a.\"AccountIdentifier\"=b.account_id;";
		ResultSet result = stmt.executeQuery(tradeDateBalanceSQL);
		while (result.next()) {
			tradeDtBalance = result.getDouble("trade_date_balance");
		}
		return tradeDtBalance;
	}

	private double getMarkeValue(Connection conn, Statement stmt, String date, String accountId) throws SQLException {
		double marketValue = 0;
		String marketValueSQL = "select TRUNC(SUM(pd.\"TradeDateQuantity\" * pr.price),2) as market_value from \"position\" p ,positiondetail pd, price pr where p.account_id='"
				+ accountId + "' and pd.position_detail_date='" + date + "' and pr.price_date='" + date
				+ "' and p.position_id=pd.position_id and p.symbol=pr.symbol group by p.account_id;";
		ResultSet result = stmt.executeQuery(marketValueSQL);
		while (result.next()) {
			marketValue = result.getDouble("market_value");
		}
		return marketValue;
	}

	private double getMarkeValuefromTransaction(Connection conn, Statement stmt, String date, String accountId)
			throws SQLException {
		double marketValuefromTrns = 0;
		String marketValuefromTrnsSQL = "select TRUNC(SUM(quantity*price),2) as reqT_marketvalue from public.transaction_history where account='"
				+ accountId + "'  and trade_dt<='" + date + "' group by account;";
		ResultSet result = stmt.executeQuery(marketValuefromTrnsSQL);
		while (result.next()) {
			marketValuefromTrns = result.getDouble("reqt_marketvalue");
		}
		return marketValuefromTrns;
	}

	/**
	 * Name = House Or NYSE
	 * 
	 * @param conn
	 * @param stmt
	 * @param date
	 * @param accountId
	 * @param name
	 * @return
	 * @throws SQLException
	 */
	private double getUnitRequirement(Connection conn, Statement stmt, String date, String accountId, double rate,double mainRate)
			throws SQLException {
		double nyseUnitReq = 0;
		String unitRequirementSql = "select p.strikepriceamount as strike_price,substring(p.symbol,2,4) as symbol,p.callputind callputind,pr.price as stock_price from public.position p, public.price pr where security_class='O' and p.account_id='"+accountId+"' and substring(p.symbol,2,4)=pr.symbol and pr.price_date='"
				+ date + "';";
		ResultSet result = stmt.executeQuery(unitRequirementSql);
		String callputind=null;
		double strikePrice =0;
		double stockPrice=0;
		while (result.next()) {
			strikePrice = result.getDouble("strike_price");
			String symbol=result.getString("symbol");
			callputind=result.getString("callputind");
			stockPrice = result.getDouble("stock_price");
		}
		// nyseUnitReq= nakedCallFor(to);
		// Get the data from the database
		return (callputind!=null && callputind.equalsIgnoreCase("C")) ? call(strikePrice,stockPrice,rate,mainRate) : put(strikePrice,stockPrice,rate,mainRate);

	}

	/**
	 * 
	 * @param strikePrice
	 * @param stockPrice
	 * @param rate
	 * @return
	 */
	private double call(double strikePrice,double stockPrice,double rate,double mainRate) {
		double ur=0;
		ur= (strikePrice > stockPrice) ? stockPrice * rate - (strikePrice - stockPrice) : stockPrice * rate;
		return (ur < stockPrice * mainRate) ? stockPrice * mainRate : ur;
	}

	/**
	 * 
	 * @param strikePrice
	 * @param stockPrice
	 * @param rate
	 * @return
	 */
	private double put(double strikePrice,double stockPrice,double rate,double mainRate) {
		double ur = 0;
		ur = (strikePrice < stockPrice) ? stockPrice * rate - (stockPrice - strikePrice) : stockPrice * rate;
		return (ur < stockPrice * mainRate) ? stockPrice * mainRate : ur;
	}

	/**
	 * 
	 * @param conn Connection
	 * @param stmt Statement
	 * @return Map<String, String>
	 * @throws SQLException
	 */
	private Map<String, RateRequirementBean> getRatesRequirements(Connection conn, Statement stmt,String accountid,String date,String securityClass)throws SQLException {
		Map<String, RateRequirementBean> rateReqMap = new LinkedHashMap();
	//	String marketValuefromTrnsSQL = "SELECT category,multiplier FROM public.requirements where security_class='O';";
		String marketValuefromTrnsSQL = "select r.category as category,r.multiplier as multiplier,p.optfactor as optfactor, pd.\"TradeDateQuantity\" as quantity from position p, positiondetail pd, requirements r where p.account_id='"+accountid+"' and p.position_id=pd.position_id and pd.position_detail_date='"+date+"'  and r.security_class='"+securityClass+"';";
		ResultSet result = stmt.executeQuery(marketValuefromTrnsSQL);
		while (result.next()) {
			RateRequirementBean rateRequirement= new RateRequirementBean();
			rateRequirement.setMultiplier(result.getDouble("multiplier"));
			rateRequirement.setOptfactor(result.getDouble("optfactor"));
			rateRequirement.setQuantity(result.getDouble("quantity"));
			String category = result.getString("category");
			rateReqMap.put(category, rateRequirement);
		}
		return rateReqMap;

	}
	
	private List<Position> getPositions(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		List<Position> positionList= new ArrayList<>();
		String positionQry = "select account_id,symbol,symbol_type,security_class from position where account_id='"+accountId+"';";
		ResultSet result = stmt.executeQuery(positionQry);
		while (result.next()) {
			Position position= new Position();
			position.setAccount_id(result.getString("account_id"));
			position.setSymbol(result.getString("symbol"));
			position.setSymbolType(result.getString("symbol_type"));
			position.setSecurityClass(result.getString("security_class"));
			positionList.add(position);
		}
		return positionList;
	}
	
	/**
	 * 
	 * @param conn
	 * @param stmt
	 * @param accountId
	 * @return
	 * @throws SQLException
	 */
	private boolean isItEligibleforStraddle(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String straddleEligibleQry = "select count(*) from position p, position c where p.account_id=c.account_id   and p.callputind = 'P' and c.callputind = 'C' and p.account_id='"+accountId+"';";
		return stmt.executeQuery(straddleEligibleQry).next();
	}
	
	private MarginCalBean performStraddleCaluculation(Connection conn, Statement stmt,String accountId,String date,Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		double nyseUnitCall=0;
		double houseUnitCall=0;
		double nyseUnitPut=0;		
		double houseUnitPut=0;
		double callOptionFactor=0;
		double putOptionFactor=0;
		double nyseUnitReq=0;
		double houseUnitReq=0;
		double callPrice=0;
		double putPrice=0;
		double callQuantity=0;
		double putQuantity=0;
		double strikePrice=0;
		String callPutInd=null;
		double stockPrice=0;
		MarginCalBean marginCalBean= new MarginCalBean();
		List<StraddleStrategyDTO> straddleDtoList = new ArrayList<>();
		//String straddleDataQry ="select po.account_id,po.price,po.strikepriceamount,po.callputind,po.optfactor,pd.\"TradeDateQuantity\" as quantity from (select p.account_id ,p.symbol ,p.position_id ,p.expirationdate ,p.price ,p.strikepriceamount ,p.callputind ,p.optfactor from position p, position c where p.position_id=c.position_id and p.account_id=c.account_id and p.expirationdate=c.expirationdate and p.strikepriceamount=c.strikepriceamount and p.account_id='"+accountId+"') po , positiondetail pd where po.position_id=pd.position_id and po.account_id='"+accountId+"';";
		String straddleDataQry ="select po.account_id,po.price,po.strikepriceamount,po.callputind,po.optfactor,pd.\"TradeDateQuantity\" as quantity,po.symbol,pr.price as stock_price from (select p.account_id ,p.symbol ,p.position_id ,p.expirationdate ,p.price ,p.strikepriceamount ,p.callputind ,p.optfactor from position p, position c where p.position_id=c.position_id and p.account_id=c.account_id and p.account_id='"+accountId+"') po , positiondetail pd, price pr where po.position_id=pd.position_id and po.account_id='"+accountId+"' and substring(po.symbol,2,4)=pr.symbol and pr.price_date='"+date+"';";
		ResultSet result = stmt.executeQuery(straddleDataQry);
		while(result.next())
		{
			StraddleStrategyDTO straddleDto = new StraddleStrategyDTO();
			straddleDto.setAccountId(result.getString("account_id"));
			straddleDto.setPrice(result.getDouble("price"));
			straddleDto.setStrikepriceamount(result.getDouble("strikepriceamount"));
			straddleDto.setCallputind(result.getString("callputind"));
			straddleDto.setOptfactor(result.getDouble("optfactor"));
			straddleDto.setQuantity(result.getDouble("quantity"));
			straddleDto.setStockPrice(result.getDouble("stock_price"));
			straddleDtoList.add(straddleDto);
		}
		
		RateRequirementBean rateRequirementforNYSE= rateRequirementsMap.get("NYSE");
		RateRequirementBean rateRequirementforHouse= rateRequirementsMap.get("House");
		RateRequirementBean rateRequirementforMaint= rateRequirementsMap.get("Maint");
		for (Iterator iterator = straddleDtoList.iterator(); iterator.hasNext();) {
			StraddleStrategyDTO straddleStrategyDTO = (StraddleStrategyDTO) iterator.next();
			if(straddleStrategyDTO.getCallputind().equalsIgnoreCase("C"))
			{
				callOptionFactor=straddleStrategyDTO.getOptfactor();
				callPrice=straddleStrategyDTO.getPrice();
				callQuantity=straddleStrategyDTO.getQuantity();
				strikePrice=straddleStrategyDTO.getStrikepriceamount();
				callPutInd=straddleStrategyDTO.getCallputind();
				stockPrice=straddleStrategyDTO.getStockPrice();
				//stockPrice=125;// ************************** Considered this as a stock price but need to be validated [NOt import , But do we need symbol in this query]
				// Prepare the unitRequirementBean from straddleStrategyDTO to pass in to getUnitRequirement1
				UnitRequirementBean unitRequirementBean= new UnitRequirementBean();
				unitRequirementBean.setStrikePrice(strikePrice);
				unitRequirementBean.setCallputind(callPutInd);
				unitRequirementBean.setStockPrice(stockPrice);
				houseUnitCall = getUnitRequirement1(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
				nyseUnitCall = getUnitRequirement1(conn, stmt, date, accountId, unitRequirementBean,rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
				//houseUnitCall= getUnitRequirement(conn, stmt, date, straddleStrategyDTO.getAccountId(), rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
				//nyseUnitCall=getUnitRequirement(conn, stmt, date, straddleStrategyDTO.getAccountId(), rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
				
			}else if(straddleStrategyDTO.getCallputind().equalsIgnoreCase("P"))
			{
				putOptionFactor=straddleStrategyDTO.getOptfactor();
				putPrice=straddleStrategyDTO.getPrice();
				putQuantity=straddleStrategyDTO.getQuantity();
				strikePrice=straddleStrategyDTO.getStrikepriceamount();
				callPutInd=straddleStrategyDTO.getCallputind();
				//stockPrice=125;
				stockPrice=straddleStrategyDTO.getStockPrice();
				UnitRequirementBean unitRequirementBean= new UnitRequirementBean();
				unitRequirementBean.setStrikePrice(strikePrice);
				unitRequirementBean.setCallputind(callPutInd);
				unitRequirementBean.setStockPrice(stockPrice);
				houseUnitPut= getUnitRequirement1(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
				nyseUnitPut=getUnitRequirement1(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
				//houseUnitPut= getUnitRequirement(conn, stmt, date, straddleStrategyDTO.getAccountId(), rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
				//nyseUnitPut=getUnitRequirement(conn, stmt, date, straddleStrategyDTO.getAccountId(), rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
			}
		}
		/**
		 * houseUnitCall -->1
		 * nyseUnitCall  --> 3
		 * houseUnitPut --> 2
		 * nyseUnitPut  --> 4
		 * callPrice --> 5
		 * putPrice --> 6
		 */
		if(houseUnitCall>houseUnitPut || houseUnitCall==houseUnitPut && callPrice < putPrice)
		{
			nyseUnitReq = (nyseUnitCall* callOptionFactor * callQuantity) + (putPrice* putOptionFactor *putQuantity);
			houseUnitReq = (houseUnitCall* callOptionFactor * callQuantity) + (putPrice* putOptionFactor *putQuantity);
		}else
		{
			nyseUnitReq=nyseUnitPut * putOptionFactor * putQuantity + (callPrice*callOptionFactor * callQuantity );
			houseUnitReq=houseUnitPut * putOptionFactor * putQuantity + (callPrice*callOptionFactor * callQuantity );
		}
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setHouseReq(houseUnitReq);
		LOGGER.info(String.format(" Straddle: NYSE Requirement = [%s] House Requirement = [%s] ", nyseUnitReq, houseUnitReq));
		
		return marginCalBean;
	}

	
	private MarginCalBean performNakedStrategyCaluculation(Connection conn, Statement stmt,String date,String accountId,Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		MarginCalBean marginCalBean= new MarginCalBean();
		UnitRequirementBean unitRequirementBean= new UnitRequirementBean();
		String unitRequirementSql = "select p.strikepriceamount as strike_price,substring(p.symbol,2,4) as symbol,p.callputind callputind,pr.price as stock_price from public.position p, public.price pr where security_class='O' and p.account_id='"+accountId+"' and substring(p.symbol,2,4)=pr.symbol and pr.price_date='"
				+date+"';";
		ResultSet result = stmt.executeQuery(unitRequirementSql);
		while (result.next()) {
			unitRequirementBean.setStrikePrice(result.getDouble("strike_price"));
			unitRequirementBean.setSymbol(result.getString("symbol"));
			unitRequirementBean.setCallputind(result.getString("callputind"));
			unitRequirementBean.setStockPrice( result.getDouble("stock_price"));
		}
		RateRequirementBean rateRequirementforNYSE= rateRequirementsMap.get("NYSE");
		RateRequirementBean rateRequirementforHouse= rateRequirementsMap.get("House");
		RateRequirementBean rateRequirementforMaint= rateRequirementsMap.get("Maint");
		double nyseUnit = getUnitRequirement1(conn, stmt, date, accountId, unitRequirementBean,rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
		double houseUnit = getUnitRequirement1(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
		double nyseUnitReq=nyseUnit * rateRequirementforNYSE.getOptfactor() * rateRequirementforNYSE.getQuantity();
		double houseUnitReq=houseUnit * rateRequirementforHouse.getOptfactor() * rateRequirementforHouse.getQuantity();
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setHouseReq(houseUnitReq);
		return marginCalBean;
	}
	

	private double getUnitRequirement1(Connection conn, Statement stmt, String date, String accountId, UnitRequirementBean unitRequirementBean,double rate,double mainRate)
			throws SQLException {
		String callputind=unitRequirementBean.getCallputind();
		double strikePrice =unitRequirementBean.getStrikePrice();
		double stockPrice=unitRequirementBean.getStockPrice();
		return (callputind!=null && callputind.equalsIgnoreCase("C")) ? call(strikePrice,stockPrice,rate,mainRate) : put(strikePrice,stockPrice,rate,mainRate);

	}

}
