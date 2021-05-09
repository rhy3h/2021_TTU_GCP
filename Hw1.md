# Hw1 Jsp & Servlet

## [Hello Get](https://rhy3h-gae.appspot.com/#HelloGet.jsp)
Add HelloGet.jsp to src/main/webapp
``` HTML
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Get Method</title>
	</head>
	
	<body class="text-center">
		<main class="form-signin">
			<%
				String username = request.getParameter("username");
				String password = request.getParameter("password");
				
				if(username != null)
					out.println("Username: " + username + "<br>");
				if(password != null)
					out.println("Password: " + password + "<br>");
			%>
	  		<form method="GET" action="/HelloGet.jsp">
				<h1 class="h3 mb-3 fw-normal">Get Method</h1>
				
				<div class="form-floating mb-3">
				  	<input type="text" class="form-control" id="username" name="username" placeholder="Username" required>
				  	<label for="Username">Username</label>
				</div>
				<div class="form-floating mb-3">
				  	<input type="password" class="form-control" id="password" name="password" placeholder="Password">
				  	<label for="password">Password</label>
				</div>
				
				<button class="w-100 btn btn-lg btn-primary" type="submit">Submit</button>
			 </form>
		</main>
	</body>
</html>
```

## [Hello Post](https://rhy3h-gae.appspot.com/#HelloGet.jsp)
Add HelloPost.jsp to src/main/webapp
``` HTML
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Post Method</title>
		<link href="/bootstrap-5.0.0/css/bootstrap.min.css" rel="stylesheet">
		<link href="signin.css" rel="stylesheet">
	</head>
	
	<body class="text-center">
		<main class="form-signin">
			
	  		<form method="POST" action="/HelloServlet">
				<h1 class="h3 mb-3 fw-normal">Post Method</h1>
				
				<div class="form-floating mb-3">
				  	<input type="text" class="form-control" id="username" name="username" placeholder="Username" required>
				  	<label for="Username">Username</label>
				</div>
				<div class="form-floating mb-3">
				  	<input type="password" class="form-control" id="password" name="password" placeholder="Password">
				  	<label for="password">Password</label>
				</div>
				
				<button class="w-100 btn btn-lg btn-primary" type="submit">Submit</button>
			 </form>
		</main>
	</body>
</html>
```
Add HelloServlet to src/main/{class}/HelloServlet.java
``` JAVA
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	// TODO Auto-generated method stub
	response.setContentType("text/html;charset=UTF-8");
	String username = request.getParameter("username");
	String password = request.getParameter("password");

	response.getWriter().println("Username: " + username + "<br>");
	response.getWriter().println("Password: " + password + "<br>");
}
```