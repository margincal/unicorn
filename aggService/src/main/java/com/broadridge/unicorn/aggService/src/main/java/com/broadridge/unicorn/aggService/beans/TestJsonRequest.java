package com.broadridge.unicorn.aggService.beans;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class TestJsonRequest {
	
public static void main (String a[]) throws JsonProcessingException
{
	List<String> accounts = new ArrayList<>();
	accounts.add("1245788");
	accounts.add("9889456");
	accounts.add("56578954");
	accounts.add("7589456");
	MarginCalRequestBean marginCalRequestBean = new MarginCalRequestBean();
	marginCalRequestBean.setAccounts(accounts);
	marginCalRequestBean.setDate("12345");
	ObjectMapper mapper = new ObjectMapper();
	String json = mapper.writeValueAsString(marginCalRequestBean);
	System.out.println("JSON = " + json);
}
	
	

}
