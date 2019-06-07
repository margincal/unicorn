package com.broadridge.unicorn.aggService.beans;

import java.io.Serializable;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
@Setter
@Getter
@EqualsAndHashCode
@NoArgsConstructor
@AllArgsConstructor
public class UnitRequirementBean implements Serializable {
	
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -2253734649386269747L;
	private double strikePrice ;
	private String  symbol;
	private String callputind;
	private double stockPrice;

}
