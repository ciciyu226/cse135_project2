<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Update XML</title>
</head>
<body>
<% 
//Check to see if logged in or not.
if(session.getAttribute("personName")==null) {
	session.setAttribute("error","PLEASE LOG IN BEFORE ENTERING OTHER PAGES");
	response.sendRedirect("login.jsp");
	return;
}
//Check to see role
%>

  <%-- Import the java.sql package --%>
  <%@ page import="java.sql.*"%>
  <%
  	Connection conn = null;
    PreparedStatement pstmt = null;
    Statement statement = null;
    Statement statement2 = null;
    Statement statement4 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    ResultSet rs2 = null;
    ResultSet rs4 = null;
    
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
        
    response.setContentType("text/xml");  
    
    String precomputed_log = "SELECT * FROM precomputed";
    //TODO: manually check the rank of each log table product after their sales in the precomputed table are updated
    
    statement = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
    	    ResultSet.CONCUR_READ_ONLY);
    /* statement2 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
    	    ResultSet.CONCUR_READ_ONLY); */
    
    
    rs = statement.executeQuery(precomputed_log);
    while(rs.next()) { %>
       	<currentRow id="<%=rs.getInt("id") %>">
       		<productHeaderCellID> 0_<%= rs.getInt("product_id") %> </productHeaderCellID>
			<productHeaderName> <%= rs.getString("product_name") %> </productHeaderName>
      		<productHeaderValue> <%= rs.getInt("product_sum") %> </productHeaderValue>
       	
			<stateHeaderCellID> <%= rs.getInt("state_id")%>_0 </stateHeaderCellID>
 			<stateHeaderName> <%= rs.getString("state_name") %> </stateHeaderName>
       		<stateHeaderValue> <%= rs.getInt("state_sum") %></stateHeaderValue>
       	
       		<innerCellID> <%= rs.getInt("state_id") %>_<%= rs.getInt("product_id") %></innerCellID>
       		<innerCellValue> <%= rs.getInt("cell_sum") %> </innerCellValue>
       	</currentRow>
 <%  }
	    
  %>
<main>
  
  <%-- -------- Close Connection Code -------- --%>
    <%  
  	  conn.close();
    }catch (SQLException e) {
      throw new RuntimeException(e);
    
    }finally {
        // Release resources in a finally block in reverse-order of
        // their creation

        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) { } // Ignore
            rs = null;
        }
        
        if (rs1 != null) {
            try {
                rs1.close();
            } catch (SQLException e) { } // Ignore
            rs1 = null;
        }
        if (rs2 != null) {
            try {
                rs2.close();
            } catch (SQLException e) { } // Ignore
            rs2 = null;
        }
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) { } // Ignore
            pstmt = null;
        }       
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) { } // Ignore
            conn = null;
        }
    }
    %>
</main>
</body>
</html>