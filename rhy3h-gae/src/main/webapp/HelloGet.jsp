<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Get Method</title>
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-wEmeIV1mKuiNpC+IOBjI7aAzPcEZeedi5yW5f2yOq55WWLwNGmvvx4Um1vskeMj0" crossorigin="anonymous">
		<link href="signin.css" rel="stylesheet">
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