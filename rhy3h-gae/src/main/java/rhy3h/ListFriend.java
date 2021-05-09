package rhy3h;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.datastore.Datastore;
import com.google.cloud.datastore.DatastoreOptions;
import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.EntityValue;
import com.google.cloud.datastore.FullEntity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.KeyFactory;
import com.google.cloud.datastore.ListValue;
import com.google.cloud.datastore.Query;
import com.google.cloud.datastore.QueryResults;
import com.google.cloud.datastore.Value;
import com.google.cloud.datastore.StructuredQuery.OrderBy;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.common.collect.Lists;

/**
 * Servlet implementation class ListFriend
 */
@WebServlet("/ListFriend")
public class ListFriend extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Datastore datastore;
	private KeyFactory keyFactory;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ListFriend() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.setContentType("text/html;charset=UTF-8");
		PrintWriter out = response.getWriter();
		
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
	Iterator<Entity> GetPhone(String name) {
		Query<Entity> query = Query.newEntityQueryBuilder()
			.setKind("Phone")
			.setFilter(PropertyFilter.eq("name", name))
		    .build();
		  
		return datastore.run(query);
	}
	
	Iterator<Entity> listFriends() {
		Query<Entity> query = Query.newEntityQueryBuilder()
			.setKind("Friend")
		    .build();
		  
		return datastore.run(query);
	}
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
