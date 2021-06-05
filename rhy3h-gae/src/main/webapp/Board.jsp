<%@ page language="java" contentType="text/html; charset=BIG5"
    pageEncoding="BIG5"%>

<%@ page 
import="java.io.FileInputStream"
import="java.io.IOException"
import="java.io.PrintWriter"
import="java.text.DateFormat"
import="java.text.SimpleDateFormat"
import="java.util.ArrayList"
import="java.util.Collections"
import="java.util.HashMap"
import="java.util.List"
import="java.util.Locale"
import="java.util.Map"

import="javax.cache.Cache"
import="javax.cache.CacheException"
import="javax.cache.CacheManager"
import="javax.servlet.ServletException"
import="javax.servlet.annotation.WebServlet"
import="javax.servlet.http.HttpServlet"
import="javax.servlet.http.HttpServletRequest"
import="javax.servlet.http.HttpServletResponse"

import="com.google.auth.oauth2.GoogleCredentials"
import="com.google.cloud.datastore.Datastore"
import="com.google.cloud.datastore.DatastoreOptions"
import="com.google.cloud.datastore.Entity"
import="com.google.cloud.datastore.Key"
import="com.google.cloud.datastore.KeyFactory"
import="com.google.cloud.datastore.Query"
import="com.google.cloud.datastore.QueryResults"
import="com.google.cloud.datastore.StructuredQuery.OrderBy"
import="com.google.cloud.datastore.StructuredQuery.PropertyFilter"
import="com.google.common.collect.Lists"
import="com.google.appengine.api.users.User"
import="com.google.appengine.api.users.UserService"
import="com.google.appengine.api.users.UserServiceFactory"
import="com.google.cloud.datastore.Transaction"
%>

<%
UserService userService = UserServiceFactory.getUserService();
User user = userService.getCurrentUser();

Datastore datastore;
KeyFactory keyFactory;

Cache cache = null;
try {
	cache = CacheManager.getInstance().getCacheFactory()
			.createCache(Collections.emptyMap());
} catch (CacheException e) {
	
}

String URL = request.getRequestURL().toString();
// Local
if(URL.indexOf("localhost") > -1) {
	String jsonPath = "/Users/rhy3h/Dropbox/Documents/rhy3h-gae-4846cd370532.json";
    GoogleCredentials credentials = GoogleCredentials.fromStream(new FileInputStream(jsonPath))
          .createScoped(Lists.newArrayList("https://www.googleapis.com/auth/cloud-platform"));
	
	datastore = DatastoreOptions.newBuilder().setCredentials(credentials).build().getService();
}
// Default
else {
	datastore = DatastoreOptions.getDefaultInstance().getService();
}
long member = new Long(0);
String number = "";
if(user != null){
	keyFactory = datastore.newKeyFactory().setKind("Member");
	
	Query<Entity> query = Query.newEntityQueryBuilder()
		.setKind("Member")
		.setFilter(PropertyFilter.eq("name", user.getNickname()))
		.build();
	QueryResults<Entity> results = (QueryResults<Entity>) datastore.run(query);
	List<Entity> entities = new ArrayList<>();
	while (results.hasNext()) {
		Entity result = results.next();
		entities.add(result);
	}
	if(entities.size() != 0){
		member = new Long(entities.get(0).getKey().getId().toString());
		number = entities.get(0).getString("number");
	}
	
	if(request.getParameter("number") != null){
		if(entities.size() == 0){
			Key key = datastore.allocateId(keyFactory.newKey());
			Entity message = Entity.newBuilder(key)
				.set("name", user.getNickname())
				.set("number", request.getParameter("number"))
				.build();
			datastore.put(message);
		} else{
			Transaction transaction = datastore.newTransaction();
			try {
			  	Entity memberEnt = transaction.get(keyFactory.newKey(member));
			    	transaction.put(
		    			Entity.newBuilder(memberEnt)
						.set("name", user.getNickname())
						.set("number", request.getParameter("number"))
						.build()
				   	);
			  	transaction.commit();
			} finally {
			  	if (transaction.isActive()) {
			    	transaction.rollback();
			  	}
			}
		}
		response.sendRedirect("/Board.jsp");
	}
}

keyFactory = datastore.newKeyFactory().setKind("Message");

List<Map<String, String>> list = null;

if (cache.containsKey("Message")) {
	list = (List<Map<String, String>>) cache.get("Message");
}
else {
	list = new ArrayList<Map<String, String>>();
	Query<Entity> query = Query.newEntityQueryBuilder()
			.setKind("Message")
			.setOrderBy(OrderBy.desc("date"))
			.build();
	QueryResults<Entity> results = (QueryResults<Entity>) datastore.run(query);
	List<Entity> entities = new ArrayList<>();
	while (results.hasNext()) {
		Entity result = results.next();
		entities.add(result);
	}
	
	DateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.TAIWAN);
	
	for (Entity e : entities) {
		Map<String, String> each = new HashMap<String, String>();
		each.put("id", e.getKey().getId().toString());
		each.put("author", e.getString("author"));
		each.put("title", e.getString("title"));
		each.put("content", e.getString("content"));
		each.put("date", inputFormat.format(e.getTimestamp("date").toDate()));
		
		list.add(each);
	}
	cache.put("Message", list);
}
%>

<!DOCTYPE html>
<html>
<head>
	<meta HTTP-EQUIV="Content-Type" content="text/html; charset=UTF-8">
	<meta HTTP-EQUIV="Expires" CONTENT="Tue, 01 Jan 1980 1:00:00 GMT">
	<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.6">
	<link rel="shortcut icon" href="favicon.ico"/>
	<title>留言板</title>
		
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-wEmeIV1mKuiNpC+IOBjI7aAzPcEZeedi5yW5f2yOq55WWLwNGmvvx4Um1vskeMj0" crossorigin="anonymous">

	<style>
	</style>
</head>
	
<body>

<main>
  <div class="container py-4">
    <header class="pb-3 mb-4 border-bottom">
      	<div class="d-flex flex-column flex-md-row align-items-center">
			<a href="/Board.jsp" class="d-flex align-items-center text-dark text-decoration-none">
        		<svg xmlns="http://www.w3.org/2000/svg" width="40" height="32" class="me-2" viewBox="0 0 118 94" role="img"><title>Bootstrap</title><path fill-rule="evenodd" clip-rule="evenodd" d="M24.509 0c-6.733 0-11.715 5.893-11.492 12.284.214 6.14-.064 14.092-2.066 20.577C8.943 39.365 5.547 43.485 0 44.014v5.972c5.547.529 8.943 4.649 10.951 11.153 2.002 6.485 2.28 14.437 2.066 20.577C12.794 88.106 17.776 94 24.51 94H93.5c6.733 0 11.714-5.893 11.491-12.284-.214-6.14.064-14.092 2.066-20.577 2.009-6.504 5.396-10.624 10.943-11.153v-5.972c-5.547-.529-8.934-4.649-10.943-11.153-2.002-6.484-2.28-14.437-2.066-20.577C105.214 5.894 100.233 0 93.5 0H24.508zM80 57.863C80 66.663 73.436 72 62.543 72H44a2 2 0 01-2-2V24a2 2 0 012-2h18.437c9.083 0 15.044 4.92 15.044 12.474 0 5.302-4.01 10.049-9.119 10.88v.277C75.317 46.394 80 51.21 80 57.863zM60.521 28.34H49.948v14.934h8.905c6.884 0 10.68-2.772 10.68-7.727 0-4.643-3.264-7.207-9.012-7.207zM49.948 49.2v16.458H60.91c7.167 0 10.964-2.876 10.964-8.281 0-5.406-3.903-8.178-11.425-8.178H49.948z" fill="currentColor"></path></svg>
        		<span class="fs-4">留言板</span>
      		</a>

			<nav class="d-inline-flex mt-2 mt-md-0 ms-md-auto">
				<a class="me-3 py-2 text-dark text-decoration-none" href="New.jsp">新增留言</a>
				<% if (user != null) { %>
				<a class="me-3 py-2 text-dark text-decoration-none" href="<%=userService.createLogoutURL("/Board.jsp") %>" target="_parent"><%=user.getNickname()%>，登出</a>
				<% } else { %>
				<a class="me-3 py-2 text-dark text-decoration-none" href="<%=userService.createLoginURL("/Board.jsp") %>" target="_parent">Anonymous，登入</a>
				<% } %>
			</nav>
		</div>
    </header>
    <% if (user != null) { %>
	<form class="row g-3" method="POST" action="">
		<label for="number" class="col-1 col-form-label">電話</label>
	  	<div class="col-auto">
	    	<label for="phone" class="visually-hidden">電話</label>
	    	<input type="text" class="form-control" name="number" value="<%=number%>" placeholder="電話">
	    	<input type="text" class="form-control" name="member" value="<%=member%>" hidden>
	  	</div>
	  	<div class="col-auto">
	    	<button type="submit" class="btn btn-primary mb-3">上傳</button>
	  	</div>
	</form>
	<% } %>
    
	<% for (Map<String, String> each : list) { %>
    <div class="p-5 mb-4 bg-light rounded-3">
      <div class="container-fluid py-5">
        <h1 class="display-5 fw-bold d-flex justify-content-between">
        	<%= each.get("title") %>
        	<div>
        		<% if (user != null && userService.isUserAdmin()) { %>
        		<a href="Edit.jsp?id=<%= each.get("id") %>" class="btn btn-primary btn-lg">修改</a>
        		<a href="Del.jsp?id=<%= each.get("id") %>" class="btn btn-danger btn-lg">刪除</a>
	        	<% } %>
        	</div>
        </h1>
        <p class="col-md-8 fs-5"><%= each.get("author") %> <%= each.get("date") %></p>
        <p class="col-md-8 fs-4"><%= each.get("content") %></p>
      </div>
    </div>
    <% } %>

    <footer class="pt-3 mt-4 text-muted border-top">
      	&copy; 2021
    </footer>
  </div>
</main>

</body>
</html>