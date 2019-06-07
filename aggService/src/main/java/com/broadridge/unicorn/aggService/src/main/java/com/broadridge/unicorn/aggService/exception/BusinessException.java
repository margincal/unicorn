package com.broadridge.unicorn.aggService.exception;

import java.io.Serializable;

public class BusinessException extends CoreException implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -3556266106049746823L;

	public BusinessException(String message) {
		super(message);

	}

	public static class BadExecution extends CoreException implements Serializable {
		private static final long serialVersionUID = 2015790613829702313L;
		public BadExecution(String message) {
			super(message);
		}
	}
	
    public static class NoData extends CoreException
    {
        private static final long serialVersionUID = 8777415230393628334L;
        public NoData(String message) {
            super(message);
        }
    }
    
 
    public static class InvalidParam extends CoreException
    {
        private static final long serialVersionUID = 4235225697094262603L;
        public InvalidParam(String message) {
            super(message);
        }
    }
    
    
    public static class InvalidDate extends CoreException
    {
		private static final long serialVersionUID = 5573076682601710110L;
		public InvalidDate(String message) {
            super(message);
        }
    }
    
    public static class AccountNotFound extends CoreException
    {
		private static final long serialVersionUID = 4531779236049724767L;
		public AccountNotFound(String message) {
            super(message);
        }
    }
    
    
	
	

}
