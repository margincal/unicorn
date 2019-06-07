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
	public Map<String,Map<String,MarginCalResponseBean>> getMarginCaluculation(MarginCalRequestBean marginCalRequestBean)
			throws SQLException {
		LOGGER.info(String.format("*****************************************************************"));
		Map<String,Map<String,MarginCalResponseBean>> marginCalResponse= new LinkedHashMap<>();	
		try {
			Connection conn = DBClient.getConnection();
			conn.setAutoCommit(false);
			Statement stmt = conn.createStatement();
			String date = marginCalRequestBean.getDate();
			List<String> accountIds = marginCalRequestBean.getAccounts();
			accountIds.parallelStream().forEach(accountid -> {
				Map<String,MarginCalResponseBean> strategyCalResponseMap= new LinkedHashMap<>();
				try {
					double tradeDtBalance = getTradeDateBalance(conn, stmt, date, accountid);
					double marketValue = getMarkeValue(conn, stmt, date, accountid);
					double marketValuefromTrns = getMarkeValuefromTransaction(conn, stmt, date, accountid);
					// Equity Caluculations
					MarginCalResponseBean marginCalResponseBean = getMarginNumbers(accountid, tradeDtBalance,	marketValue, marketValuefromTrns);
					strategyCalResponseMap.put("Equ",marginCalResponseBean);
					//Get positions List
						List<Position> positionList= getPositions( conn, stmt,accountid) ;
						Position position=positionList.get(0);
						int positionsList=positionList.size();
						String securityClass=position.getSecurityClass();
					Map<String,RateRequirementBean> rateRequirementsMap=null;
					if(securityClass !=null && securityClass.equalsIgnoreCase("O"))
					{
						rateRequirementsMap=getRatesRequirements(conn, stmt,accountid,date,securityClass);
						if(positionsList==2)
						{
							boolean isEligible=isItEligibleforStraddle( conn,  stmt, accountid);
							if(isEligible)
							{
								MarginCalResponseBean starddleMarginCalResponse= new MarginCalResponseBean();
								MarginCalBean marginCalBean= performStraddleCaluculation( conn,stmt,accountid,date,rateRequirementsMap);
								starddleMarginCalResponse.setMargin(marginCalBean);
								strategyCalResponseMap.putIfAbsent("Straddle", starddleMarginCalResponse);
							}
						}else if(positionsList == 1)
						{
							MarginCalResponseBean nakedMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean= performNakedStrategyCaluculation(conn,  stmt, accountid, date,rateRequirementsMap);
							nakedMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("Naked", nakedMarginCalResponse);
						}
						if(isItEligibleforMarriedOptions(conn,stmt,accountid))
						{
							MarginCalResponseBean marriedMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean margin=performMarriedOptionCaluculation( conn,  stmt, accountid, date, rateRequirementsMap);
							marriedMarginCalResponse.setMargin(margin);
							strategyCalResponseMap.putIfAbsent("Married", marriedMarginCalResponse);
						}

						if(isItEligibleforCovered( conn,  stmt, accountid))   // Added by Khalid
						{
							MarginCalResponseBean coveredMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean = performCoveredStrategyCalculation(conn,stmt,accountid,date,marketValue,tradeDtBalance);
							coveredMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("Covered", coveredMarginCalResponse);
						}
						if (isItEligibleforCollars( conn,  stmt, accountid)) 
						{
							MarginCalResponseBean collarsMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean = performCollarsStrategyCalculation(conn,stmt,accountid,date,marketValue,rateRequirementsMap);
							collarsMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("Collars", collarsMarginCalResponse);							
						}
						if (isItEligibleforForwardConversions( conn,  stmt, accountid)) 
						{
							MarginCalResponseBean conversionsMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean = performForwardConversionStrategyCalculation(conn,stmt,accountid,date,rateRequirementsMap);
							conversionsMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("ForwardConversion", conversionsMarginCalResponse);							
						}
						if (isItEligibleforReverseConversions( conn,  stmt, accountid)) 
						{
							MarginCalResponseBean conversionsMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean = performReverseConversionStrategyCalculation(conn,stmt,accountid,date,rateRequirementsMap);
							conversionsMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("ReverseConversion", conversionsMarginCalResponse);							
						}
						if (isItEligibleforBankLetterGuarantee( conn,  stmt, accountid)) 
						{
							MarginCalResponseBean conversionsMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean = performBankLetterGuaranteeCalculation(conn,stmt,accountid,date,rateRequirementsMap);
							conversionsMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("BankLetterGuarantee", conversionsMarginCalResponse);							
						}
						if (isItEligibleforEscrewReciept( conn,  stmt, accountid)) 
						{
							MarginCalResponseBean conversionsMarginCalResponse= new MarginCalResponseBean();
							MarginCalBean marginCalBean = performEscrewRecieptCalculation(conn,stmt,accountid,date,rateRequirementsMap);
							conversionsMarginCalResponse.setMargin(marginCalBean);
							strategyCalResponseMap.putIfAbsent("EscrewReciept", conversionsMarginCalResponse);							
						}
					}
				} catch (SQLException e) {
				}
				marginCalResponse.put(accountid, strategyCalResponseMap);
			});
		} catch (Exception e) {
		}
		LOGGER.info(String.format("*****************************************************************"));
		return marginCalResponse;
	}

	private MarginCalResponseBean getMarginNumbers(String accountId, double tradeDtBalance, double marketValue,
			double marketValuefromTrns) {
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
		double maintenanceExcess = (double) maintenance / 0.3;
		double regTexcess = regT * 2;
		LOGGER.info(String.format("MaintenanceExcess = [%s] RegTexcess = [%s] ", maintenance, regT));
		double buyingPower = (maintenanceExcess > regTexcess) ? regTexcess : maintenanceExcess;
		maginCal.setBuyPower(buyingPower);
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
		Map<String, RateRequirementBean> rateReqMap = new LinkedHashMap<>();
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
		ResultSet rs=stmt.executeQuery(straddleEligibleQry);
		boolean result=false;
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		return result;
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
		String straddleDataQry ="select po.account_id,po.price,po.strikepriceamount,po.callputind,po.optfactor,pd.\"TradeDateQuantity\" as quantity,po.symbol,pr.price as stock_price from (select p.account_id ,p.symbol ,p.position_id ,p.expirationdate ,p.price ,p.strikepriceamount ,p.callputind ,p.optfactor from position p, position c where p.position_id=c.position_id and p.account_id=c.account_id and p.account_id='"+accountId+"') po , positiondetail pd, price pr where po.position_id=pd.position_id and po.account_id='"+accountId+"' and substring(po.symbol from '[^ ]+'::text)=concat('@',pr.symbol) and pr.price_date='"+date+"';";
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
		for (Iterator<StraddleStrategyDTO> iterator = straddleDtoList.iterator(); iterator.hasNext();) {
			StraddleStrategyDTO straddleStrategyDTO = (StraddleStrategyDTO) iterator.next();
			if(straddleStrategyDTO.getCallputind().equalsIgnoreCase("C"))
			{
				callOptionFactor=straddleStrategyDTO.getOptfactor();
				callPrice=straddleStrategyDTO.getPrice();
				callQuantity=straddleStrategyDTO.getQuantity();
				strikePrice=straddleStrategyDTO.getStrikepriceamount();
				callPutInd=straddleStrategyDTO.getCallputind();
				stockPrice=straddleStrategyDTO.getStockPrice();
				UnitRequirementBean unitRequirementBean= new UnitRequirementBean();
				unitRequirementBean.setStrikePrice(strikePrice);
				unitRequirementBean.setCallputind(callPutInd);
				unitRequirementBean.setStockPrice(stockPrice);
				houseUnitCall = getUnitRequirement(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
				nyseUnitCall = getUnitRequirement(conn, stmt, date, accountId, unitRequirementBean,rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
			}else if(straddleStrategyDTO.getCallputind().equalsIgnoreCase("P"))
			{
				putOptionFactor=straddleStrategyDTO.getOptfactor();
				putPrice=straddleStrategyDTO.getPrice();
				putQuantity=straddleStrategyDTO.getQuantity();	
				strikePrice=straddleStrategyDTO.getStrikepriceamount();
				callPutInd=straddleStrategyDTO.getCallputind();
				stockPrice=straddleStrategyDTO.getStockPrice();
				UnitRequirementBean unitRequirementBean= new UnitRequirementBean();
				unitRequirementBean.setStrikePrice(strikePrice);
				unitRequirementBean.setCallputind(callPutInd);
				unitRequirementBean.setStockPrice(stockPrice);
				houseUnitPut= getUnitRequirement(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
				nyseUnitPut=getUnitRequirement(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
			}
		}
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

	
	private MarginCalBean performNakedStrategyCaluculation(Connection conn, Statement stmt,String accountId,String date,Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		MarginCalBean marginCalBean= new MarginCalBean();
		UnitRequirementBean unitRequirementBean= new UnitRequirementBean();
		String unitRequirementSql = "select p.strikepriceamount as strike_price,substring(p.symbol from '[^ ]+'::text) as symbol,p.callputind callputind,pr.price as stock_price from public.position p, public.price pr where security_class='O' and p.account_id='"+accountId+"' and substring(p.symbol from '[^ ]+'::text)=concat('@',pr.symbol) and pr.price_date='"
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
		double nyseUnit = getUnitRequirement(conn, stmt, date, accountId, unitRequirementBean,rateRequirementforNYSE.getMultiplier(),rateRequirementforMaint.getMultiplier());
		double houseUnit = getUnitRequirement(conn, stmt, date, accountId,unitRequirementBean, rateRequirementforHouse.getMultiplier(),rateRequirementforMaint.getMultiplier());
		double nyseUnitReq=nyseUnit * rateRequirementforNYSE.getOptfactor() * rateRequirementforNYSE.getQuantity();
		double houseUnitReq=houseUnit * rateRequirementforHouse.getOptfactor() * rateRequirementforHouse.getQuantity();
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setHouseReq(houseUnitReq);
		return marginCalBean;
	}
	

	private double getUnitRequirement(Connection conn, Statement stmt, String date, String accountId, UnitRequirementBean unitRequirementBean,double rate,double mainRate)
			throws SQLException {
		String callputind=unitRequirementBean.getCallputind();
		double strikePrice =unitRequirementBean.getStrikePrice();
		double stockPrice=unitRequirementBean.getStockPrice();
		return (callputind!=null && callputind.equalsIgnoreCase("C")) ? call(strikePrice,stockPrice,rate,mainRate) : put(strikePrice,stockPrice,rate,mainRate);

	}
	
	/**
	 * 
	 * @param conn
	 * @param stmt
	 * @param accountId
	 * @return
	 * @throws SQLException
	 */
	private boolean isItEligibleforMarriedOptions(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String marriedOptionsEligibleQry = "select count(1) from position p, position e,positiondetail pd, positiondetail pe where p.account_id=e.account_id and p.security_class='O' and e.security_class='E' and p.account_id='"+accountId +"' and substring(p.symbol from '[^ ]+'::text)=concat('@',e.symbol) and p.position_id=pd.position_id and e.position_id=pe.position_id and abs(pd.\"TradeDateQuantity\"*p.optfactor)=abs(pe.\"TradeDateQuantity\") and sign(pd.\"TradeDateQuantity\")=1;";
		ResultSet rs=stmt.executeQuery(marriedOptionsEligibleQry);
		boolean result=false;
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		return result;
	}
	
	
	private MarginCalBean performMarriedOptionCaluculation(Connection conn, Statement stmt,String accountId,String date,Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		double stockPrice=0;
		double strikePrice=0;
		double optionFactor=0;
		double optionQuantity=0;
		double nyseUnitReq=0;
		double houseUnitReq=0;
		String callputind=null;
		MarginCalBean marginCalBean= new MarginCalBean();
		String MarriedOptionDataQry ="select p.account_id ,p.symbol ,e.symbol ,p.callputind ,pd.\"TradeDateQuantity\" as OptionQuantity ,pe.\"TradeDateQuantity\" as EquityQuantity ,p.optfactor ,p.strikepriceamount as strike_price ,pr.price as stock_price from position p, position e,public.positiondetail pd, positiondetail pe, price pr where  p.account_id=e.account_id and p.account_id='"+accountId+"' and p.security_class='O' and e.security_class='E' and p.account_id='"+accountId+"'  and substring(p.symbol from '[^ ]+'::text)=concat('@',e.symbol) and p.position_id=pd.position_id and e.position_id=pe.position_id and abs(pd.\"TradeDateQuantity\"*p.optfactor)=abs(pe.\"TradeDateQuantity\") and e.symbol=pr.symbol";
		RateRequirementBean rateRequirementforNYSE= rateRequirementsMap.get("MarriedNYSE");
		RateRequirementBean rateRequirementforHouse= rateRequirementsMap.get("MarriedHouse");
		double nrr=rateRequirementforNYSE.getMultiplier();
		double hrr=rateRequirementforHouse.getMultiplier();
		ResultSet result = stmt.executeQuery(MarriedOptionDataQry);
		while(result.next())
		{
			stockPrice=result.getDouble("stock_price");
			strikePrice=result.getDouble("strike_price");
			callputind=result.getString("callputind");
			optionFactor=result.getDouble("optfactor");
			optionQuantity=result.getDouble("OptionQuantity");
		}
		nyseUnitReq= (callputind!= null && callputind.equalsIgnoreCase("C")) ? marriedOptionCall(strikePrice,stockPrice,optionFactor,optionQuantity,nrr) : marriedOptionPut(strikePrice,stockPrice,optionFactor,optionQuantity,nrr);
		houseUnitReq=(callputind!= null && callputind.equalsIgnoreCase("C")) ? marriedOptionCall(strikePrice,stockPrice,optionFactor,optionQuantity,hrr) : marriedOptionPut(strikePrice,stockPrice,optionFactor,optionQuantity,hrr);
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setHouseReq(houseUnitReq);
		LOGGER.info(String.format(" Married: NYSE Requirement = [%s] House Requirement = [%s] ", nyseUnitReq, houseUnitReq));
		return marginCalBean;
	}
	
	private double marriedOptionCall(double strikePrice,double stockPrice, double optionFactor,double optionQuantity,double rate)
	{
		return (stockPrice< strikePrice) ? (strikePrice - stockPrice) * optionFactor * optionQuantity + strikePrice * rate * optionFactor * optionQuantity: strikePrice * rate * optionFactor * optionQuantity;
	}
	
	
	private double marriedOptionPut(double strikePrice,double stockPrice, double optionFactor,double optionQuantity,double rate)
	{
		return (stockPrice > strikePrice) ? (stockPrice - strikePrice) * optionQuantity * optionFactor + strikePrice * rate * optionFactor * optionQuantity: strikePrice * rate * optionFactor * optionQuantity;
		
	}
	
	/** Following code added by Khalid
	 * 
	 * @param conn
	 * @param stmt
	 * @param accountId
	 * @return
	 * @throws SQLException
	 */
	private boolean isItEligibleforCovered(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String coveredEligibleQry = "select count(1) from position p, position e,positiondetail pd, positiondetail pe " 
									+ " where p.account_id=e.account_id "
									+ " and p.security_class='O' "
									+ " and e.security_class='E' "
									+ " and p.account_id= '" + accountId + "'"
									+ " and substring(p.symbol from '[^ ]+'::text)=concat('@',e.symbol)"
									+ " and p.position_id=pd.position_id "
									+ " and e.position_id=pe.position_id "
									+ " and abs(pd.\"TradeDateQuantity\" * p.optfactor)=abs(pe.\"TradeDateQuantity\") and sign(pd.\"TradeDateQuantity\")=-1";
		ResultSet rs=stmt.executeQuery(coveredEligibleQry);
		boolean result=false; 
		while (rs.next()) 
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		return result;
	}
	

	private MarginCalBean performCoveredStrategyCalculation(Connection conn, Statement stmt, String accountId, String date, double marketValue, double tradeDtBalance)throws SQLException
	{
		double stockPrice=0;
		double strikePrice=0;
		double houseReqPercent=0;
		double nyseReqPercent=0;
		double optionFactor=0;
		double optionQuantity=0;
		String callPutInd=null;
		String symbol = null;
		
		double increaseInhouseUnitReqUnderlying = 0;
		double totalIncreaeUnderlyingHouseReq = 0;
		
		double increaseNyseUnitReqUnderlying = 0;
		double totalIncreaeUnderlyingNyseReq = 0;
		
		double totalHouseRequirement = 0;
		double totalNyseRequirement = 0;
		
		double nyseEquityRequirement = Math.abs(getEquityRequirements(conn, stmt, "NYSE",marketValue, accountId, date));
		double houseEquityRequirement = Math.abs(getEquityRequirements(conn, stmt, "House",marketValue, accountId, date));
		
		LOGGER.info(String.format("nyseRequirement  = [%s] ", nyseEquityRequirement));
		LOGGER.info(String.format("houseRequirement = [%s] ", houseEquityRequirement));
		
		MarginCalBean marginCalBean= new MarginCalBean();
		
		String unitRequirementSql = "select 	p.account_id ,p.symbol as p_symbol ,e.symbol as e_symbol, p.callputind ,pd.\"TradeDateQuantity\" as OptionQuantity "
				+ " ,pe.\"TradeDateQuantity\" as EquityQuantity ,p.optfactor as optFactor ,p.strikepriceamount as strike_price ,pr.price as stock_price " 
		        + " from position p, position e,public.positiondetail pd, positiondetail pe, price pr "
		        + " where p.account_id=e.account_id and p.security_class='O' and e.security_class='E' and p.account_id='" + accountId + "'"
		        + " and substring(p.symbol from '[^ ]+'::text)=concat('@',e.symbol) and p.position_id=pd.position_id and e.position_id=pe.position_id "
		        + " and abs(pd.\"TradeDateQuantity\" * p.optfactor) = abs(pe.\"TradeDateQuantity\")	and e.symbol=pr.symbol ";
		
		ResultSet result = stmt.executeQuery(unitRequirementSql);
		while (result.next()) {
			strikePrice = result.getDouble("strike_price");
			symbol = result.getString("p_symbol");
			callPutInd = result.getString("callputind");
			stockPrice =  result.getDouble("stock_price");
			optionFactor = result.getDouble("optFactor");
			optionQuantity= result.getDouble("OptionQuantity");
		}
		
		houseReqPercent  = getUnderlyingRequirementRate(conn,stmt,"LongHouse");
		nyseReqPercent   = getUnderlyingRequirementRate(conn,stmt,"LongNYSE");
		
		if ( callPutInd.equalsIgnoreCase("C")) {
		
			increaseInhouseUnitReqUnderlying = (strikePrice - stockPrice) * (1 - houseReqPercent);
			totalIncreaeUnderlyingHouseReq = increaseInhouseUnitReqUnderlying * optionFactor * Math.abs(optionQuantity);
			totalHouseRequirement = totalIncreaeUnderlyingHouseReq + houseEquityRequirement;
		
			increaseNyseUnitReqUnderlying = (strikePrice - stockPrice) * (1 - nyseReqPercent);
			totalIncreaeUnderlyingNyseReq = increaseNyseUnitReqUnderlying * optionFactor * Math.abs(optionQuantity);
			totalNyseRequirement = totalIncreaeUnderlyingNyseReq + nyseEquityRequirement;
		
		} else if ( callPutInd.equalsIgnoreCase("P")) {
			
			increaseInhouseUnitReqUnderlying = strikePrice - stockPrice;
			totalIncreaeUnderlyingHouseReq = increaseInhouseUnitReqUnderlying * optionFactor * Math.abs(optionQuantity);
			totalHouseRequirement = totalIncreaeUnderlyingHouseReq + houseEquityRequirement;
			
			totalIncreaeUnderlyingNyseReq = totalIncreaeUnderlyingHouseReq; // Same as house since no rate involved.
			totalNyseRequirement = totalIncreaeUnderlyingNyseReq + nyseEquityRequirement;
		}
		
		marginCalBean.setHouseReq(totalHouseRequirement);
		marginCalBean.setNyseReq(totalNyseRequirement);
		
		return marginCalBean;
	}
	
	private double getEquityRequirements (Connection conn, Statement stmt, String orgType, double marketValue, String accountId, String date) throws SQLException {
		
		double equityRequirement = 0;
		
		double tradeDateQuantity = getTradeDateQuantity(conn,  stmt,  date,  accountId);
		
		if ( tradeDateQuantity < 0 ) {
			equityRequirement = marketValue * getUnderlyingRequirementRate(conn, stmt, "Short" + orgType);
		
		} else {
			equityRequirement = marketValue * getUnderlyingRequirementRate(conn, stmt, "Long" + orgType);
		}
		
		return equityRequirement;
	}
	
	private double getTradeDateQuantity(Connection conn, Statement stmt, String date, String accountId) throws SQLException {
		double tradeDateQuantity = 0;
		String 	quantitySQL = "select pd.\"TradeDateQuantity\" as tradeDtQuantity from \"position\" p ,positiondetail pd, price pr where p.account_id='"
				+ accountId + "' and pd.position_detail_date='" + date + "' and pr.price_date='" + date
				+ "' and p.position_id=pd.position_id and p.symbol=pr.symbol;";
		
		ResultSet result = stmt.executeQuery(quantitySQL);
		while (result.next()) {
			tradeDateQuantity = result.getDouble("tradeDtQuantity");
		}
		return tradeDateQuantity;
	}
	
	private double getUnderlyingRequirementRate(Connection conn, Statement stmt, String orgType) throws SQLException {
		
		double rate = 0;
		
		String rateSql = "select multiplier from public.requirements where security_class='E' and category='" + orgType + "'";
		
		ResultSet result = stmt.executeQuery(rateSql);
		while (result.next()) {
			rate = result.getDouble("multiplier");
		}
		
		return rate;
	}

	//   End of code by Khalid **************************************8
	
	private boolean isItEligibleforCollars(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String collarsEligibleQry = "select count(1) from position p, position e,positiondetail pd, positiondetail pe where p.account_id=e.account_id and p.security_class='O' and e.security_class='E' and p.account_id='"+accountId +"' and substring(p.symbol from '[^ ]+'::text)=concat('@',e.symbol) and p.position_id=pd.position_id and e.position_id=pe.position_id and abs(pd.\"TradeDateQuantity\"*p.optfactor)=abs(pe.\"TradeDateQuantity\") and sign(pd.\"TradeDateQuantity\")=1;";
		ResultSet rs=stmt.executeQuery(collarsEligibleQry);
		boolean result=false;
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		return result;
	}
	
	
	private MarginCalBean performCollarsStrategyCalculation(Connection conn, Statement stmt, String accountId, String date, double marketValue, Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		
		double stockPrice = 0;
		double putStrike = 0;
		double callStrike = 0;
		double nyseUnitReq = 0;
		double houseUnitReq = 0;
		String callputind=null;
		double optionFactor=0;
		double optionQuantity=0;
		double underlyingRequirement = 0;
		
		MarginCalBean marginCalBean= new MarginCalBean();
		
		String CollarsOptionDataQry= "select lp.account_id ,lp.symbol as longputsymbol,sc.symbol as shortcallsymbol,e.symbol as equitysymbol" + 
									 ",lp.price,lp.strikepriceamount as putstrike,sc.strikepriceamount as callstrike,pr.price as stockprice" +
									 ",lp.optfactor,pdl.\"TradeDateQuantity\" as longquantity,pds.\"TradeDateQuantity\" as shortquantity" +
									 ",pde.\"TradeDateQuantity\" as equityquantity" +
									 " from position lp, position sc, position e, positiondetail pdl, positiondetail pds, positiondetail pde, price pr" +
									 " where lp.account_id=sc.account_id and lp.account_id=e.account_id " +
									 " and substring(lp.symbol from '[^ ]+'::text)=substring(sc.symbol from '[^ ]+'::text)" +
									 " and substring(lp.symbol from '[^ ]+'::text)=concat('@',e.symbol)" +
									 " and lp.expirationdate=sc.expirationdate and lp.strikepriceamount<=sc.strikepriceamount" +
									 " and lp.position_id=pdl.position_id and sc.position_id=pds.position_id and e.position_id=pde.position_id" +
									 " and abs(pdl.\"TradeDateQuantity\"*lp.optfactor)=abs(pde.\"TradeDateQuantity\") and lp.callputind='P'" +
									 " and sc.callputind='C' and e.symbol=pr.symbol	and lp.account_id='" + accountId  + "'"  +
									 " and pr.price_date='" + date + "'";
		
		
		ResultSet result = stmt.executeQuery(CollarsOptionDataQry);
		while(result.next())
		{
			stockPrice=result.getDouble("stockprice");
			putStrike=result.getDouble("putstrike");
			callStrike=result.getDouble("callstrike");
			optionFactor=result.getDouble("optfactor");
			optionQuantity=result.getDouble("longquantity");
		}
		// nyseUnitReq= (callputind!= null && callputind.equalsIgnoreCase("C")) ? marriedOptionCall(strikePrice,stockPrice,optionFactor,optionQuantity,nrr) : marriedOptionPut(strikePrice,stockPrice,optionFactor,optionQuantity,nrr);
		// houseUnitReq=(callputind!= null && callputind.equalsIgnoreCase("C")) ? marriedOptionCall(strikePrice,stockPrice,optionFactor,optionQuantity,hrr) : marriedOptionPut(strikePrice,stockPrice,optionFactor,optionQuantity,hrr);
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setHouseReq(houseUnitReq);
		LOGGER.info(String.format(" Collars: NYSE Requirement = [%s] House Requirement = [%s] ", nyseUnitReq, houseUnitReq));
		
		// Calculate NYSE Requirement:
		
		nyseUnitReq = putStrike * 0.1;
		
		if ( stockPrice > putStrike) {
			nyseUnitReq = nyseUnitReq + ( stockPrice - putStrike);
			underlyingRequirement = (stockPrice - putStrike) * optionQuantity * optionFactor;
		}
		
		if ( nyseUnitReq > (callStrike * 0.25)) {
			nyseUnitReq = callStrike * 0.25;
		}
		
		nyseUnitReq = nyseUnitReq * optionQuantity * optionFactor;
		
		// Calculate House Requirement:
		
		RateRequirementBean collarRateReqForCallHouse= rateRequirementsMap.get("CallHRR");
		RateRequirementBean collarRateReqForPutHouse= rateRequirementsMap.get("PutHRR");
		
		double callHrr=collarRateReqForCallHouse.getMultiplier();
		double putHrr=collarRateReqForPutHouse.getMultiplier();
		
		houseUnitReq = putStrike * putHrr;
		
		if ( stockPrice > putStrike) {
			houseUnitReq = houseUnitReq + (stockPrice - putStrike);
		}
		
		if ( houseUnitReq > (callStrike * callHrr)) {
			houseUnitReq = callStrike * callHrr;
		}
		houseUnitReq = houseUnitReq * optionQuantity * optionFactor;
		
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setNyseUnderlying(underlyingRequirement);
		
		marginCalBean.setHouseReq(houseUnitReq);
		marginCalBean.setHouseUnderlying(underlyingRequirement);
			
		return marginCalBean;
		
	}
	
	private boolean isItEligibleforForwardConversions(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String conversionsEligibleQry = "select count(1) from position lp, position sc, position e, positiondetail pdl, positiondetail pde" +
										" where lp.account_id=sc.account_id and lp.account_id=e.account_id" + 
										" and substring(lp.symbol from '[^ ]+'::text)=substring(sc.symbol from '[^ ]+'::text)" +
										" and substring(lp.symbol from '[^ ]+'::text)=concat('@',e.symbol)" +
										" and lp.expirationdate=sc.expirationdate and lp.strikepriceamount=sc.strikepriceamount" +
										" and lp.callputind <> sc.callputind and lp.position_id=pdl.position_id" +
										" and e.position_id=pde.position_id" +
										" and abs(pdl.\"TradeDateQuantity\"*lp.optfactor)=abs(pde.\"TradeDateQuantity\")" +
										" and sign(pdl.\"TradeDateQuantity\"*lp.optfactor)=1 and lp.account_id='" + accountId + "'";
				
		ResultSet rs=stmt.executeQuery(conversionsEligibleQry);
		boolean result=false;
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		return result;
	}
	
	private MarginCalBean performForwardConversionStrategyCalculation(Connection conn, Statement stmt, String accountId, String date, Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		
		double stockPrice = 0;
		double putStrike = 0;
		double callStrike = 0;
		double nyseUnitReq = 0;
		double houseUnitReq = 0;
		String callputind=null;
		double optionFactor=0;
		double putQuantity=0;
		double houseUnderlyingReq = 0;
		double nyseUnderlyingReq = 0;
		double marketValue = 0;
		double houseReqPercent = 0;
		double nyseReqPercent = 0;
		double underlyingNyseReqIncrease = 0;
		double underlyingHouseReqIncrease = 0;
		
		
		String ForwardConvQuery= "select lp.account_id, lp.symbol as longputsymbol, sc.symbol as shortcallsymbol, e.symbol as equitysymbol" +
								 ", lp.price as price, lp.strikepriceamount as putstrike, sc.strikepriceamount as callstrike, pr.price as stockprice" +
								 ", lp.optfactor, pdl.\"TradeDateQuantity\" as putquantity, (pde.\"TradeDateQuantity\"*pr.price) as market_value" +
								 " from position lp, position sc, position e, positiondetail pdl, positiondetail pde, price pr" +
								 " where lp.account_id=sc.account_id and lp.account_id=e.account_id" +
								 " and substring(lp.symbol from '[^ ]+'::text)=substring(sc.symbol from '[^ ]+'::text)" +
								 " and substring(lp.symbol from '[^ ]+'::text)=concat('@',e.symbol)	and lp.expirationdate=sc.expirationdate" +
								 " and lp.strikepriceamount=sc.strikepriceamount and lp.callputind <> sc.callputind" +
								 " and lp.position_id=pdl.position_id and e.position_id=pde.position_id" +
								 " and abs(pdl.\"TradeDateQuantity\"*lp.optfactor)=abs(pde.\"TradeDateQuantity\")" +
								 " and sign(pdl.\"TradeDateQuantity\"*lp.optfactor)=1 and lp.account_id='" + accountId + "'" + 
								 " and pr.price_date='" + date + "'";
		
		ResultSet result = stmt.executeQuery(ForwardConvQuery);
		while(result.next())
		{
			marketValue=result.getDouble("market_value");
			stockPrice=result.getDouble("stockprice");
			putStrike=result.getDouble("putstrike");
			optionFactor=result.getDouble("optfactor");
			putQuantity=result.getDouble("putquantity");
		}
	
		houseReqPercent  = getUnderlyingRequirementRate(conn,stmt,"LongHouse");
		nyseReqPercent   = getUnderlyingRequirementRate(conn,stmt,"LongNYSE");
		
		houseUnderlyingReq = marketValue * houseReqPercent;
		nyseUnderlyingReq  = marketValue * nyseReqPercent;
		
		RateRequirementBean houseRateReqForFCHouse= rateRequirementsMap.get("FCHouse");
		RateRequirementBean nyseRateReqForFCNyse= rateRequirementsMap.get("FCNYSE");
		
		double fcHouseRate=houseRateReqForFCHouse.getMultiplier();
		double fcNyseRate=nyseRateReqForFCNyse.getMultiplier();
		
		houseUnitReq = putStrike * fcHouseRate * putQuantity * optionFactor;
		nyseUnitReq = putStrike * fcNyseRate * putQuantity * optionFactor;
		
		underlyingNyseReqIncrease = (stockPrice - putStrike ) * putQuantity * optionFactor;
		
		if ( underlyingNyseReqIncrease < 0)
			underlyingNyseReqIncrease = 0;
		
		underlyingHouseReqIncrease = (stockPrice - putStrike ) * putQuantity * optionFactor;
		
		if ( underlyingHouseReqIncrease < 0)
			underlyingHouseReqIncrease = 0;
		

		MarginCalBean marginCalBean= new MarginCalBean();
		
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setNyseUnderlying(nyseUnderlyingReq);
		marginCalBean.setNyseUnderlyingReqIncrease(underlyingNyseReqIncrease);
		
		marginCalBean.setHouseReq(houseUnitReq);
		marginCalBean.setHouseUnderlying(houseUnderlyingReq);
		marginCalBean.setHouseUnderlyingReqIncrease(underlyingHouseReqIncrease);
		
		return marginCalBean;
		
	}
	
	private boolean isItEligibleforReverseConversions(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String conversionsEligibleQry = "select count(1) from position lp, position sc, position e, positiondetail pdl, positiondetail pde" +
										" where lp.account_id=sc.account_id and lp.account_id=e.account_id" + 
										" and substring(lp.symbol from '[^ ]+'::text)=substring(sc.symbol from '[^ ]+'::text)" +
										" and substring(lp.symbol from '[^ ]+'::text)=concat('@',e.symbol)" +
										" and lp.expirationdate=sc.expirationdate and lp.strikepriceamount=sc.strikepriceamount" +
										" and lp.callputind <> sc.callputind and lp.position_id=pdl.position_id" +
										" and e.position_id=pde.position_id" +
										" and abs(pdl.\"TradeDateQuantity\"*lp.optfactor)=abs(pde.\"TradeDateQuantity\")" +
										" and sign(pdl.\"TradeDateQuantity\"*lp.optfactor)=-1 and lp.account_id='" + accountId + "'";
				
		ResultSet rs=stmt.executeQuery(conversionsEligibleQry);
		boolean result=false;
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		return result;
	}
	
	private MarginCalBean performReverseConversionStrategyCalculation(Connection conn, Statement stmt, String accountId, String date, Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		
		double stockPrice = 0;
		double putStrike = 0;
		double callStrike = 0;
		double nyseUnitReq = 0;
		double houseUnitReq = 0;
		String callputind=null;
		double optionFactor=0;
		double putQuantity=0;
		double houseUnderlyingReq = 0;
		double nyseUnderlyingReq = 0;
		double marketValue = 0;
		double houseReqPercent = 0;
		double nyseReqPercent = 0;
		double underlyingNyseReqIncrease = 0;
		double underlyingHouseReqIncrease = 0;
		
		
		String ForwardConvQuery= "select lp.account_id, lp.symbol as longputsymbol, sc.symbol as shortcallsymbol, e.symbol as equitysymbol" +
								 ", lp.price as price, lp.strikepriceamount as putstrike, sc.strikepriceamount as callstrike, pr.price as stockprice" +
								 ", lp.optfactor, pdl.\"TradeDateQuantity\" as putquantity, (pde.\"TradeDateQuantity\"*pr.price) as market_value" +
								 " from position lp, position sc, position e, positiondetail pdl, positiondetail pde, price pr" +
								 " where lp.account_id=sc.account_id and lp.account_id=e.account_id" +
								 " and substring(lp.symbol from '[^ ]+'::text)=substring(sc.symbol from '[^ ]+'::text)" +
								 " and substring(lp.symbol from '[^ ]+'::text)=concat('@',e.symbol)	and lp.expirationdate=sc.expirationdate" +
								 " and lp.strikepriceamount=sc.strikepriceamount and lp.callputind <> sc.callputind" +
								 " and lp.position_id=pdl.position_id and e.position_id=pde.position_id" +
								 " and abs(pdl.\"TradeDateQuantity\"*lp.optfactor)=abs(pde.\"TradeDateQuantity\")" +
								 " and sign(pdl.\"TradeDateQuantity\"*lp.optfactor)=1 and lp.account_id='" + accountId + "'" + 
								 " and pr.price_date='" + date + "'";
		
		ResultSet result = stmt.executeQuery(ForwardConvQuery);
		while(result.next())
		{
			marketValue=result.getDouble("market_value");
			stockPrice=result.getDouble("stockprice");
			putStrike=result.getDouble("putstrike");
			optionFactor=result.getDouble("optfactor");
			putQuantity=result.getDouble("putquantity");
		}
	
		houseReqPercent  = getUnderlyingRequirementRate(conn,stmt,"LongHouse");
		nyseReqPercent   = getUnderlyingRequirementRate(conn,stmt,"LongNYSE");
		
		houseUnderlyingReq = marketValue * houseReqPercent;
		nyseUnderlyingReq  = marketValue * nyseReqPercent;
		
		RateRequirementBean houseRateReqForFCHouse= rateRequirementsMap.get("RCHouse");
		RateRequirementBean nyseRateReqForFCNyse= rateRequirementsMap.get("RCNYSE");
		
		double fcHouseRate=houseRateReqForFCHouse.getMultiplier();
		double fcNyseRate=nyseRateReqForFCNyse.getMultiplier();
		
		houseUnitReq = putStrike * fcHouseRate * putQuantity * optionFactor;
		nyseUnitReq = putStrike * fcNyseRate * putQuantity * optionFactor;
		
		underlyingNyseReqIncrease = (stockPrice - putStrike ) * putQuantity * optionFactor;
		
		if ( underlyingNyseReqIncrease < 0)
			underlyingNyseReqIncrease = 0;
		
		underlyingHouseReqIncrease = (stockPrice - putStrike ) * putQuantity * optionFactor;
		
		if ( underlyingHouseReqIncrease < 0)
			underlyingHouseReqIncrease = 0;
		

		MarginCalBean marginCalBean= new MarginCalBean();
		
		marginCalBean.setNyseReq(nyseUnitReq);
		marginCalBean.setNyseUnderlying(nyseUnderlyingReq);
		marginCalBean.setNyseUnderlyingReqIncrease(underlyingNyseReqIncrease);
		
		marginCalBean.setHouseReq(houseUnitReq);
		marginCalBean.setHouseUnderlying(houseUnderlyingReq);
		marginCalBean.setHouseUnderlyingReqIncrease(underlyingHouseReqIncrease);
		
		return marginCalBean;
		
	}
	
	private boolean isItEligibleforBankLetterGuarantee(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String bankLetterGuaranteeEligibleQry = "select count(1) from position p,position e, positiondetail pd" +
												" where p.account_id=e.account_id and p.position_id=pd.position_id" +
												" and p.security_class='O' and p.callputind='P' and e.security_class='BLG'" +
												" and sign(pd.\"TradeDateQuantity\")=-1 and p.account_id='" + accountId + "'";		
		
		ResultSet rs=stmt.executeQuery(bankLetterGuaranteeEligibleQry);
		boolean result=false;
		
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		
		return result;
	}
	
	private MarginCalBean performBankLetterGuaranteeCalculation(Connection conn, Statement stmt, String accountId, String date, Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		double blgQuantity=0;
		double marketValue=0;
		double lowerValue= 0;
		
		String bankLetterGrntyQry = "select p.account_id,p.symbol,abs(p.optfactor * pd.\"TradeDateQuantity\") as market_value" +
		                            ", pde.\"TradeDateQuantity\" as blg_quantity from position p,position e, positiondetail pd, positiondetail pde" +
		                            " where p.account_id=e.account_id and p.position_id=pd.position_id and e.position_id=pde.position_id" +
		                            " and p.security_class='O' and p.callputind='P' and e.security_class='BLG' and sign(pd.\"TradeDateQuantity\")=-1" +
		                            " and p.account_id='" + accountId + "'";
		
		ResultSet result = stmt.executeQuery(bankLetterGrntyQry);
		while(result.next())
		{
			marketValue=result.getDouble("market_value");
			blgQuantity = result.getDouble("blg_quantity");
		}
		
		if (marketValue < blgQuantity)
			lowerValue = marketValue;
		else
			lowerValue = blgQuantity;
		
		MarginCalBean marginCalBean= new MarginCalBean();
		
		marginCalBean.setBLGQty(lowerValue);
		
		return marginCalBean;
		
		
	}
	
	private boolean isItEligibleforEscrewReciept(Connection conn, Statement stmt,String accountId) throws SQLException
	{
		String escrewRcptEligibleQry = "select count(1) from position p,position e, positiondetail pd" +
									   " where p.account_id=e.account_id and p.position_id=pd.position_id and p.security_class='O'" +
									   " and p.callputind='C' and e.security_class='ESC' and sign(pd.\"TradeDateQuantity\")=-1" +
									   " and p.account_id='" + accountId + "'";		
		
		ResultSet rs=stmt.executeQuery(escrewRcptEligibleQry);
		boolean result=false;
		
		while(rs.next())
		{
			result =(rs.getInt("count")>0)? true:result;
		}
		
		return result;
	}
	
	private MarginCalBean performEscrewRecieptCalculation(Connection conn, Statement stmt, String accountId, String date, Map<String,RateRequirementBean> rateRequirementsMap)throws SQLException
	{
		double escrewRcptQuantity=0;
		double marketValue=0;
		double lowerValue= 0;
	
		String escrewRecieptQry = "select p.account_id,p.symbol,abs(p.optfactor * pd.\"TradeDateQuantity\") as market_value" +
                ", pde.\"TradeDateQuantity\" as esc_rcpt_quantity from position p,position e, positiondetail pd, positiondetail pde" +
                " where p.account_id=e.account_id and p.position_id=pd.position_id and e.position_id=pde.position_id" +
                " and p.security_class='O' and p.callputind='C' and e.security_class='ESC' and sign(pd.\"TradeDateQuantity\")=-1" +
                " and p.account_id='" + accountId + "'";

		ResultSet result = stmt.executeQuery(escrewRecieptQry);
		while(result.next())
		{
			marketValue=result.getDouble("market_value");
			escrewRcptQuantity = result.getDouble("esc_rcpt_quantity");
		}
		
		if (marketValue < escrewRcptQuantity)
			lowerValue = marketValue;
		else
			lowerValue = escrewRcptQuantity;
		
		MarginCalBean marginCalBean= new MarginCalBean();
		marginCalBean.setEscrowReceiptQty(lowerValue);
		
		return marginCalBean;
	}
}
