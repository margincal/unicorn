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
public class MarginCalBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -2724622167389383608L;

	private double regT;
	private double house;
	private double maintenance;
	private double buyPower;
	private double nyseReq;
	private double nyseUnderlying;
	private double nyseUnderlyingReqIncrease;
	private double houseReq;
	private double houseUnderlying;
	private double houseUnderlyingReqIncrease;
	private double BLGQty;
	private double EscrowReceiptQty;
}
