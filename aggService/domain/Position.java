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
public class Position implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 193809110122182468L;
	
	private String account_id;
	private String symbol;
	private String symbolType;
	private String securityClass;
}
