package com.broadridge.unicorn.aggService.exception;

public class TestExceptions {
	
	
	public static void main(String[] args)
    {
        try
        {
            throw new BusinessException.NoData("No row found for id : x");
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
    }

}
