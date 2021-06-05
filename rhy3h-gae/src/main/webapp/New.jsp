<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
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
import="com.google.cloud.Timestamp"
import="com.google.cloud.datastore.Datastore"
import="com.google.cloud.datastore.DatastoreOptions"
import="com.google.cloud.datastore.Entity"
import="com.google.cloud.datastore.Key"
import="com.google.cloud.datastore.KeyFactory"
import="com.google.cloud.datastore.Query"
import="com.google.cloud.datastore.QueryResults"
import="com.google.cloud.datastore.StructuredQuery.OrderBy"
import="com.google.common.collect.Lists"
import="com.google.cloud.datastore.Transaction"
import="com.google.appengine.api.users.User"
import="com.google.appengine.api.users.UserService"
import="com.google.appengine.api.users.UserServiceFactory"
%>

<%
UserService userService = UserServiceFactory.getUserService();
User user = userService.getCurrentUser();

if(request.getParameter("cancel") != null){
	response.sendRedirect("/Board.jsp");
}
Datastore datastore;
KeyFactory keyFactory;

Cache cache = null;
try {
	cache = CacheManager.getInstance().getCacheFactory()
			.createCache(Collections.emptyMap());
} catch (CacheException e) {
	
}
cache.remove("Message");

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

keyFactory = datastore.newKeyFactory().setKind("Message");

String title = "";
String content = "";
String author = "Anonymous";

if(request.getParameter("title") != null){
	title = request.getParameter("title");
}
if(request.getParameter("content") != null){
	content = request.getParameter("content");
}
if(user != null){
	author = user.getNickname();
}

if(request.getParameter("submit") != null){
	if(!title.equals("") && !content.equals("")){
		 Key key = datastore.allocateId(keyFactory.newKey());
		 Entity message = Entity.newBuilder(key)
		 	.set("author", author)
	    	.set("title", title)
	    	.set("content", content)
	    	.set("date", Timestamp.now())
		    .build();
		 datastore.put(message);
		 
		 response.sendRedirect("/Board.jsp");
	}
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
	<title>新增留言</title>
		
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
				<% if (user != null) { %>
				<a class="py-2 text-dark text-decoration-none" href="<%=userService.createLogoutURL("/New.jsp") %>" target="_parent"><%=user.getNickname()%>，登出</a>
				<% } else { %>
				<a class="py-2 text-dark text-decoration-none" href="<%=userService.createLoginURL("/New.jsp") %>" target="_parent">Anonymous，登入</a>
				<% } %>
			</nav>
		</div>
    </header>
    
    <div class="p-5 mb-4 bg-light rounded-3">
      <div class="container-fluid py-5">
		<form method="POST" action="">
		<div class="mb-3">
		  <label for="title" class="form-label">標題</label>
		  <input type="text" class="form-control" name="title" value="<%=title%>" required>
		</div>
		<div class="mb-3">
		  <label for="content" class="form-label">內容</label>
		  <textarea class="form-control" name="content" rows="5" required><%=content%></textarea>
		</div>
		<div class="row">
			<div class="col">
				<a class="w-100 btn btn-lg btn-secondary" href="/Board.jsp">取消</a>
			</div>
			<div class="col">
				<button class="w-100 btn btn-lg btn-primary" name="submit" type="submit">送出留言</button>
			</div>
		</div>
		</form>
      </div>
    </div>

    <footer class="pt-3 mt-4 text-muted border-top">
      	&copy; 2021
    </footer>
  </div>
</main>

</body>

</html>