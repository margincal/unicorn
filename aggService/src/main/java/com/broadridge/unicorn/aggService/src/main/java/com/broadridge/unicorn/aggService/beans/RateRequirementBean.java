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
public class RateRequirementBean implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -5400698159037341239L;
	private double multiplier;
	private double optfactor;
	private double quantity;

}
