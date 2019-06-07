package com.broadridge.unicorn.aggService.beans;

import java.io.Serializable;
import java.util.List;

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
public class MarginCalRequestBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4539829047649952935L;

	private List<String> accounts;

	private String date;

}
