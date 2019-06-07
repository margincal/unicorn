package com.broadridge.unicorn.aggService.exception;

import java.io.Serializable;

public class CoreException extends Exception implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4938714130123730635L;
	private String message;

	public CoreException(String message) {
		this.message = message;
	}

	public String getMessage() {
		return message;
	}

}
