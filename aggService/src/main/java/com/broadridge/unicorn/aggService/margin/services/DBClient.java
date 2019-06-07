package com.broadridge.unicorn.aggService.margin.services;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.DriverManager;

public class DBClient implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = -8969622866065061613L;
  

	 public static Connection getConnection() {
		 Connection conn=null;
	      try {
		         Class.forName("org.postgresql.Driver");
		         conn = DriverManager
		            .getConnection("jdbc:postgresql://localhost:5432/postgres",
		            "postgres", "postgres");
		         conn.setAutoCommit(false);
		         System.out.println("Opened database successfully");
		      } catch ( Exception e ) {
		         System.err.println( e.getClass().getName()+": "+ e.getMessage() );
		         System.exit(0);
		      }
		return conn;
	 }
	
}
