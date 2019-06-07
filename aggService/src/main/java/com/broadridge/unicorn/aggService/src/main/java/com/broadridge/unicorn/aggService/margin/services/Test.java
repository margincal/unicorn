package com.broadridge.unicorn.aggService.margin.services;

public class Test {

	public static void main(String[] args) {
		
		double tradeDtBalance= 6000.0;
		double marketValue=10000.0;
		
		double equity=marketValue-tradeDtBalance;
		int perc=100;
	
		double regT=equity-(double)(50 * marketValue) / 100;
		double house=equity-(double)(30 * marketValue) / 100;
		double nyse=equity-(double)(25 * marketValue) / 100;
		System.out.println(regT);
		System.out.println(house);
		System.out.println(nyse);


	}

}
