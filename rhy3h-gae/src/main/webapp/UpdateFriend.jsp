<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Update Friend</title>
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-wEmeIV1mKuiNpC+IOBjI7aAzPcEZeedi5yW5f2yOq55WWLwNGmvvx4Um1vskeMj0" crossorigin="anonymous">
		<link href="signin.css" rel="stylesheet">
	</head>
	
	<body class="text-center">
		<main class="form-signin">
  			<form action="UpdateFriend">
    			<h1 class="h3 mb-3 fw-normal">Update Friend</h1>
			
			    <div class="form-floating mb-3">
			      	<input type="text" class="form-control" id="name" name="name" placeholder="Name" required>
			      	<label for="name">Name</label>
			    </div>
			    <div class="form-floating mb-3">
			      	<input type="email" class="form-control" id="email" name="email" placeholder="Email">
			      	<label for="email">Email</label>
			    </div>
			    <div class="form-floating mb-3">
			      	<input type="text" class="form-control" id="type" name="type" placeholder="Type">
			      	<label for="type">Type</label>
			    </div>
			    <div class="form-floating mb-3">
			      	<input type="text" class="form-control" id="phone" name="phone"  placeholder="Phone">
			      	<label for="phone">Phone</label>
			    </div>
			    
			    <button class="w-100 btn btn-lg btn-primary" type="submit">Update</button>
			  </form>
		</main>
  	</body>
</html>