/**
 * 
 */
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
public class MarginCalResponseBean implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -3926345638303737167L;

	private String accountNo;	
	private MarginCalBean margin;
	
}
