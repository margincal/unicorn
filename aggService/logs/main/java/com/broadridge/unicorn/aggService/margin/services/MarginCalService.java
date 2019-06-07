/**
 * 
 */
package com.broadridge.unicorn.aggService.margin.services;

import java.io.Serializable;
import java.sql.SQLException;

import com.broadridge.unicorn.aggService.beans.MarginCalRequestBean;

public interface MarginCalService extends Serializable{
	
	
	/**
	 * 
	 * @return Object
	 * @throws SQLException 
	 */
	public Object getMarginCaluculation(MarginCalRequestBean marginCalRequestBean) throws SQLException;
	

}
