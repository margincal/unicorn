package com.broadridge.unicorn.aggService.beans;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class TestJsonReponse {

	public static void main(String[] args) throws JsonProcessingException {
		List<MarginCalResponseBean> response = new ArrayList<>();
		// Bean1
		MarginCalResponseBean marginCalResponseBean= new MarginCalResponseBean();
		marginCalResponseBean.setAccountNo("1254");
		MarginCalBean marginCalBean= new MarginCalBean();
		marginCalBean.setRegT(12435.00);
		marginCalBean.setHouse(56489.00);
		marginCalBean.setMaintenance(4568.00);
		marginCalResponseBean.setMargin(marginCalBean);
		// Bean2
		MarginCalResponseBean marginCalResponseBean1= new MarginCalResponseBean();
		marginCalResponseBean1.setAccountNo("7854");
		MarginCalBean marginCalBean1= new MarginCalBean();
		marginCalBean1.setRegT(348565.00);
		marginCalBean1.setHouse(87594.00);
		marginCalBean1.setMaintenance(874568.00);
		marginCalResponseBean1.setMargin(marginCalBean1);
		//response
		response.add(marginCalResponseBean);
		response.add(marginCalResponseBean1);
		
		ObjectMapper mapper = new ObjectMapper();
		String json = mapper.writeValueAsString(response);
		System.out.println("JSON = " + json);
		
	}

}
