/**
 * 
 */
package com.broadridge.unicorn.aggService.margin;

import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.broadridge.unicorn.aggService.beans.MarginCalRequestBean;
import com.broadridge.unicorn.aggService.constants.RestUriConstants;
import com.broadridge.unicorn.aggService.margin.services.MarginCalService;

@RestController
public class MarginCalController {

	@Autowired
	MarginCalService marginCalService;
	private final Logger LOGGER = LoggerFactory.getLogger(this.getClass());
	@RequestMapping(path = RestUriConstants.GET_MARGIN_CAL, produces={"application/json"} ,method = RequestMethod.POST)
	public Object performMarginCaluculation(@RequestBody MarginCalRequestBean marginCalRequestBean) throws SQLException {
		return marginCalService.getMarginCaluculation(marginCalRequestBean); 
		
	}
	
	
	
	
	
	
	
}
