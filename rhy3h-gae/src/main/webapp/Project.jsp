<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Collections"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.TimeZone"%>
<%@ page import="com.google.cloud.datastore.Key"%>
<%@ page import="com.google.cloud.datastore.KeyFactory"%>
<%@ page import="com.google.cloud.datastore.Datastore"%>
<%@ page import="com.google.cloud.datastore.DatastoreOptions"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>
<%@ page import="com.google.cloud.datastore.Entity"%>
<%@ page import="com.google.cloud.datastore.Query"%>
<%@ page import="com.google.cloud.datastore.QueryResults"%>
<%@ page import="com.google.cloud.datastore.StructuredQuery.OrderBy"%>
<%@ page import="com.google.cloud.datastore.StructuredQuery.PropertyFilter"%>
<%@ page import="javax.cache.Cache"%>
<%@ page import="javax.cache.CacheException"%>
<%@ page import="javax.cache.CacheFactory"%>
<%@ page import="javax.cache.CacheManager"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="/stylesheets/main.css" type="text/css" rel="stylesheet"></link>
<title>Main Page</title>
</head>
<body>
	<div class="main_panel">
		<%
			String searchKeyword = request.getParameter("keyword");

			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			sdf.setTimeZone(TimeZone.getTimeZone("Asia/Taipei"));

			Cache cache = null;
			try {
				cache = CacheManager.getInstance().getCacheFactory()
						.createCache(Collections.emptyMap());
			} catch (CacheException e) {
			}

			UserService userService = UserServiceFactory.getUserService();
			User user = userService.getCurrentUser();
		%>
		<!-- 使用到 Google 認證 -->
		<div class="sign">
			<%
				if (user != null) {
			%>
			<a href="<%=userService.createLogoutURL("/") %>" target="_parent">登出</a> <%=user.getNickname()%>
			<p />
			<form class="search" action="/uploadtel" method="post">
				<div>上傳電話</div>
				<input type="text" size="20" name="phone"></input> <input
					type="submit" value="送出"></input>
			</form>
			<%
				} else {
			%>
			<a href="<%=userService.createLoginURL("/main.jsp") %>" target="_parent">登入</a> Anonymous
			<p />
			<%
				}
			%>
		</div>
			<form class="search" action="main.jsp" method="post">
				<div>搜尋留言</div>
				<input type="text" size="30" name="keyword"></input>
				<input type="submit" value="搜尋"></input>
			</form>
			<div class="guestbook">
				<a href="post_message.jsp">新增留言</a>
			</div>
		<p />
		<div class="board_header">
			<%
				if (searchKeyword != null) {
			%>
			<a href="main.jsp" target="_self">返回留言板</a><span> 搜尋關鍵字：<%=searchKeyword%></span>
			<%
				} else {
			%>
			<div>留言板</div>
			<%
				}
			%>
		</div>
		<%
			List<Map<String, String>> list = null;
			if (cache.containsKey("msg-cache") && searchKeyword == null) {
				list = (List<Map<String, String>>) cache.get("msg-cache");
			} else {
				list = new ArrayList<Map<String, String>>();
				Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
				Query<Entity> query = Query.newEntityQueryBuilder().setKind("Message")
						.setOrderBy(OrderBy.asc("date")).build();
				QueryResults<Entity> results= (QueryResults<Entity>) datastore.run(query);
				List<Entity> entities = new ArrayList<>();
				while (results.hasNext()) {
					Entity result = results.next();
					entities.add(result);
				}
				
				for (Entity e : entities) {
					if (searchKeyword != null && !e.getString("title").contains(searchKeyword))
						continue;

					Map<String, String> each = new HashMap<String, String>();
					// each.put("key", ..... // get the key & convert to appropriate string
					each.put("title", e.getString("title"));
					each.put("author", e.getString("author"));
					each.put("date", sdf.format(e.getTimestamp("date").toDate())); //e.getTimestamp("date").toString());

					list.add(each);
				}
				if (searchKeyword == null)
					cache.put("msg-cache", list);
			}
		%>
		<div>
			<%
				for (Map<String, String> each : list) {
			%>
			<div class="row">
				<%
					if (user != null && userService.isUserAdmin()) {
					//判斷若為管理者時加入修改&刪除的連結，並設定傳遞參數msg-key的值
				%>
				<div class="col">
					<a href="revise_message.jsp?msg-key=<%=each.get("key")%>">修改</a>
				</div>
				<div class="col">
					<a href="deletemessage?msg-key=<%=each.get("key")%>">刪除</a>
				</div>
				<%
					}
				%>
				<div class="col"><%=each.get("date")%></div>
				<div class="col"><%=each.get("author")%></div>
				<div class="col">
					<a href="view_message.jsp?msg-key=<%=each.get("key")%>"><%=each.get("title")%></a>
				</div>
			</div>
			<%
				}
			%>
		</div>
	</div>
</body>
</html>