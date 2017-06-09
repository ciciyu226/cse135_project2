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
<title>New Sales Report</title>
</head>
<body>
<% 
long startTime = System.currentTimeMillis();
//Check to see if logged in or not.
if(session.getAttribute("personName")==null) {
	session.setAttribute("error","PLEASE LOG IN BEFORE ENTERING OTHER PAGES");
	response.sendRedirect("login.jsp");
	return;
}
//Check to see role
%>
<header>
	<h2>Hello <%=session.getAttribute("personName") %>!</h2>
</header>
  <%-- Import the java.sql package --%>
  <%@ page import="java.sql.*"%>
  <%
  	Connection conn = null;
    PreparedStatement pstmt = null;
    Statement statement = null;
    Statement statement1 = null;
    Statement statement2 = null;
    Statement statement4 = null;
    Statement statement_updateCell = null;
    Statement statement_updateState = null;
    Statement statement_updateProduct = null;
    Statement statement_emptyLog = null;
    Statement statement_checkLog = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    ResultSet rs2 = null;
    ResultSet rs4 = null;
    ResultSet rs_product = null;
    ResultSet rs_state = null;
    ResultSet rs_cell = null;
    ResultSet rs_emptyLog = null;
    ResultSet rs_checkLog = null;
    
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
        
    String checkLog = "SELECT * FROM logs";
    String update_cellSum = 
    		"WITH added_totals AS("
			+ "SELECT state_id, state_name, product_id, product_name, SUM(added) AS added FROM logs"
			+ " GROUP BY state_id, state_name, product_id, product_name)"
    		+ "UPDATE precomputed pre"
    		+ " SET cell_sum=(cell_sum+l.added)"
    		+ " FROM added_totals l"
    		+ " WHERE pre.state_id=l.state_id"
    		+ " AND pre.product_id=l.product_id";    
    String update_stateSum = "WITH T AS( SELECT state_id, sum(added) AS total FROM logs GROUP BY state_id )"
    + " UPDATE precomputed pre"
    + " SET state_sum=(state_sum+T.total)"
    + "	FROM T"
    + "	WHERE pre.state_id=T.state_id";
    String update_productSum = "WITH T AS( SELECT product_id, sum(added) AS total FROM logs GROUP BY product_id )"
    + " UPDATE precomputed pre"
    + "	SET product_sum=(product_sum+T.total)"
    + "	FROM T"
    + "	WHERE pre.product_id=T.product_id";     
    String update_log = "DELETE FROM logs WHERE true";
    
        
    String precomputed = "SELECT * FROM precomputed";
    String prod_header;
    if(request.getParameter("sort_category")!=null && !request.getParameter("sort_category").equals("all")){
    	prod_header = "SELECT DISTINCT product_id, product_name, product_sum FROM precomputed WHERE category_id=" + request.getParameter("sort_category")
    			+ " ORDER BY product_sum DESC LIMIT 50";
    }
    else{
    	prod_header = "SELECT DISTINCT product_id, product_name, product_sum FROM precomputed ORDER BY product_sum DESC LIMIT 50";
    }
    String state_header = "SELECT DISTINCT state_id, state_name, state_sum FROM precomputed ORDER BY state_sum DESC";
    
    statement = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
    	    ResultSet.CONCUR_READ_ONLY);
    statement1 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
    	    ResultSet.CONCUR_READ_ONLY);
    statement2 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
    	    ResultSet.CONCUR_READ_ONLY);
    statement_updateCell = conn.createStatement();
    statement_updateState = conn.createStatement();
    statement_updateProduct = conn.createStatement();
    statement_emptyLog = conn.createStatement();
    statement_checkLog = conn.createStatement();

  %>
<main>
  <ul id="newProduct"></ul>
  
  <button id="btn-refresh" onclick="getXML()"> Refresh</button>
  <form action="newSales.jsp" method="GET">
  <select name="sort_category">
	  	  <%if(request.getParameter("sort_category")!=null && !request.getParameter("sort_category").equals("all")){
	  		  %>
			<option value="<%=request.getParameter("sort_category")%>"><%=request.getParameter("sort_category")%></option>
	  	  <%} %>
	  	    <option value="all">All</option>
		  	<% statement4 = conn.createStatement();
		  	rs4 = statement4.executeQuery("SELECT * FROM category");
		  	while(rs4.next()){
		  		if( request.getParameter("sort_category")!=null && !request.getParameter("sort_category").equals("all")
		  				&& rs4.getString("category_name").equals(request.getParameter("sort_category"))){
		  		}
		  		else{
		  		%>
		  		<option value="<%=rs4.getInt("id")%>"><%=rs4.getString("category_name")%></option>
		  	<%	}  
		  	}%>
  </select>
  <input type="submit" name="runQuery" value="Run Query" />
 </form>  
  <%if(request.getParameter("runQuery") != null && request.getParameter("runQuery").equals("Run Query")) { 
	  conn.setAutoCommit(false);
	  rs_checkLog = statement_checkLog.executeQuery(checkLog);
	  if(rs_checkLog.next()){
	  System.out.println("start updating precomputed table with logs");
	  statement_updateCell.executeUpdate(update_cellSum);
	  System.out.println("Cell sums are updated");
	  statement_updateProduct.executeUpdate(update_productSum);
	  System.out.println("Product sums are updated");
	  statement_updateState.executeUpdate(update_stateSum);
	  System.out.println("State sums are updated");
	  statement_emptyLog.executeUpdate(update_log);
	  System.out.println("log table is emptied");
	  }
	  
	  rs = statement.executeQuery(precomputed);
	  rs1 = statement1.executeQuery(prod_header);
	  rs2 = statement2.executeQuery(state_header);
	  conn.commit();
	  conn.setAutoCommit(true);
  %>
  <table id="salesTable" border="1">  	
  	<tr>
  	  <td>State / Product </td>
      <% while(rs1.next()) { %>
  	  <th class="products" id="0_<%=rs1.getInt("product_id")%>"><span><%= rs1.getString("product_name") %></span><br>($ <span id="total"><%=rs1.getInt("product_sum") %></span>)</th>  
      <% } %>
  	</tr>
  	<% while(rs2.next()){ %>
  	<tr>
  	  <th id="<%=rs2.getInt("state_id")%>_0"><span><%= rs2.getString("state_name") %></span><br>($ <span id="total"><%=rs2.getInt("state_sum") %></span>)</th>
  	  <%
	  	 /* big table for searching products bought by current user */
	      if(request.getParameter("sort_category")!=null && !request.getParameter("sort_category").equals("all")){
	    	  pstmt = conn.prepareStatement("SELECT * FROM precomputed WHERE state_name = ? AND category_id = ? ORDER BY product_sum DESC LIMIT 50");
	    	  pstmt.setString(1, rs2.getString("state_name"));
	    	  pstmt.setInt(2, Integer.parseInt(request.getParameter("sort_category")));
	      }else{
		  	pstmt = conn.prepareStatement("SELECT * FROM precomputed WHERE state_name = ? ORDER BY product_sum DESC LIMIT 50");
	  	  	pstmt.setString(1, rs2.getString("state_name"));
	      }
	  	  rs = pstmt.executeQuery();
	  	  while (rs.next()) { %>
	  		<td id="<%= rs.getInt("state_id")%>_<%= rs.getInt("product_id")%>"><%= rs.getInt("cell_sum") %></td>
	  	<% } %> 
  	</tr> 
  	<% } %> 	
  </table>
  <%} %>
 
  <button id="btn-refresh" onclick="getXML()"> Refresh</button> 	  
  <%-- -------- Close Connection Code -------- --%>
    <%  
  	  conn.close();
    }catch (SQLException e) {
    	System.out.println(e.getSQLState());
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
        long endTime   = System.currentTimeMillis();
    	long totalTime = endTime - startTime;
    	System.out.println("TOTAL RUNTIME IN MS WAS: " + totalTime);
    }
    %>
</main>
</body>
<script src="app.js"></script>
</html>
