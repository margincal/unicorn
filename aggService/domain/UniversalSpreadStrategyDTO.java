package com.broadridge.unicorn.aggService.domain;

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

public class UniversalSpreadStrategyDTO implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 2283009651727816175L;
	private String accountId;
	private double price;
	private double strikepriceamount;
	private String callputind;
	private double optfactor;
	private double quantity;
	private double stockPrice;
	private String expirationDate;

}
