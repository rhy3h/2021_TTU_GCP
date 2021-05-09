# Hw4 Datastore Query & Update

## Deploy Webiste
[rhy3h-gae](https://rhy3h-gae.appspot.com)

## Crendentials
Because of local and website's crendentials method is not the same way
So I write a easy way to determine how to credential
``` JAVA
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	// TODO Auto-generated method stub
	String URL = request.getRequestURL().toString();
	// Local
	if(URL.indexOf("localhost") > -1) {
		String jsonPath = "/Users/rhy3h/Dropbox/Documents/rhy3h-gae-4846cd370532.json";
		GoogleCredentials credentials = GoogleCredentials.fromStream(new FileInputStream(jsonPath))
			  .createScoped(Lists.newArrayList("https://www.googleapis.com/auth/cloud-platform"));
		
		datastore = DatastoreOptions.newBuilder().setCredentials(credentials).build().getService();
		keyFactory = datastore.newKeyFactory().setKind("Friend");
	}
	// Default
	else {
		datastore = DatastoreOptions.getDefaultInstance().getService();
		keyFactory = datastore.newKeyFactory().setKind("Friend");
	}
}
```

## [Add New Friend](https://rhy3h-gae.appspot.com/#NewFriend.jsp)
Add NewFriend.java to src/main/{class}/NewFriend.java
``` JAVA
Key AddNewFriend(String name, String email, ListValue phones) {
	Key key = keyFactory.newKey(name);
	Entity friend = Entity.newBuilder(key)
			.set("name", name)
			.set("email", email)
			.set("phone", phones)
			.build();
	datastore.put(friend);
	return key;
}
```

``` JAVA
Key newPhone(String type, String num, String name) {
	KeyFactory keyFactory2 = datastore.newKeyFactory()
			.addAncestor(PathElement.of("Friend", name))
			.setKind("Phone");
	Key key = keyFactory2.newKey(name + "_" + type);
	Entity phone = Entity.newBuilder(key)
			.set("name", name)
			.set("type", type)
			.set("number", num)
			.build();
	datastore.put(phone);
	return key;
```

Use 2 function to add new Friend, and url will redirect to ListFriend
``` JAVA
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	String name = request.getParameter("name");
	String email = request.getParameter("email");
	String type = request.getParameter("type");
	String phone = request.getParameter("phone");
	
	FullEntity<?> newPhone = datastore.get(newPhone(type, phone, name));
	ListValue listPhone = ListValue.of(newPhone);
	AddNewFriend(name, email, listPhone);
	
	response.sendRedirect("ListFriend");
}
```

## [List Friend](https://rhy3h-gae.appspot.com/#ListFriend)
Add ListFriend.java to src/main/{class}/ListFriend.java
``` JAVA
Iterator<Entity> listFriends() {
	Query<Entity> query = Query.newEntityQueryBuilder()
		.setKind("Friend")
		.build();
	
	return datastore.run(query);
}
```

``` JAVA
Iterator<Entity> GetPhone(String name) {
	Query<Entity> query = Query.newEntityQueryBuilder()
		.setKind("Phone")
		.setFilter(PropertyFilter.eq("name", name))
		.build();
	
	return datastore.run(query);
}
```

``` JAVA
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	QueryResults<Entity> friends = (QueryResults<Entity>) listFriends();
	List<Entity> friends_entities = Lists.newArrayList();
	while (friends.hasNext()) {
		Entity result = friends.next();
		friends_entities.add(result);
	}
	
	out.println("<h1>Friend List</h1>");
	for (Entity friend : friends_entities){
		if (friend == null)
			continue;
		
		out.println("<h2>");
		out.println("Name: " + friend.getString("name") + "<br>");
		out.println("Email: " + friend.getString("email") + "<br>");
		
		out.println("Phones: ");
		ListValue phones = ((ListValue) friend.getValue("phone"));
		List<? extends Value<?>> list = phones.get();
		out.println("<ul>");
		for(Value<?> item : list) {
			FullEntity<?> phoneEntity = ((EntityValue) item).get();
			out.println("<li>");
			out.println(phoneEntity.getString("type") + ": " + phoneEntity.getString("number"));
			out.println("</li>");
		}
		out.println("</ul>");
		
		out.println("</h2>");
	}
}
```