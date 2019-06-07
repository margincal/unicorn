package com.broadridge.unicorn.aggService.margin.services;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.broadridge.unicorn.aggService.beans.MarginCalBean;
import com.broadridge.unicorn.aggService.beans.MarginCalRequestBean;
import com.broadridge.unicorn.aggService.beans.MarginCalResponseBean;
import com.broadridge.unicorn.aggService.domain.Position;

public class CoveredOptionsStrategy {
	
	/*
	 * Covered call – Short calls vs long underlying.
	   Covered put – short puts vs short underlying.
	   
 	Quantity of underlying must be equal to quantity (factor * quantity) of options.

	*** Covered put ***
	Increase in Unit Requirement of Underlying = Strike price – stock price

	Total Increase of Underlying Requirement = 
	       Unit Requirement Increase of Underlying * Total Quantity of Covered Puts
                 = (Strike price – stock price) *  option factor * option quantity

	*** Covered call ***
	Increase in Unit Requirement of Underlying = (Strike price – stock price)*(1 – requirement % of underlying)

	Total Increase of Underlying Requirement 
	      = Unit Requirement Increase of Underlying * Total Quantity of Covered Calls
 			= (Strike price – stock price)*(1 – requirement % of underlying) * option factor * option quantity
	 */
	
	public double performCoveredOptionStrategyCalculation(Connection conn, Statement stmt,String accountid,String date,String securityClass)
			throws SQLException {
		
		
		
		return 0;
	}
	

}
