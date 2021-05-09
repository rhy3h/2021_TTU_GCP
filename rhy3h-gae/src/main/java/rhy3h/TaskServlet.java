package rhy3h;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
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
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.Datastore;
import com.google.cloud.datastore.DatastoreOptions;
import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.KeyFactory;
import com.google.cloud.datastore.Query;
import com.google.cloud.datastore.QueryResults;
import com.google.cloud.datastore.StringValue;
import com.google.cloud.datastore.StructuredQuery.OrderBy;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.common.collect.Lists;

/**
 * Servlet implementation class TaskServlet
 */
@WebServlet("/TaskServlet")
public class TaskServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Datastore datastore;
	private KeyFactory keyFactory;
	
    /**
     * @throws IOException 
     * @throws FileNotFoundException 
     * @see HttpServlet#HttpServlet()
     */
    public TaskServlet() throws FileNotFoundException, IOException {
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
		    keyFactory = datastore.newKeyFactory().setKind("Task");
		}
		// Default
		else {
			datastore = DatastoreOptions.getDefaultInstance().getService();
			keyFactory = datastore.newKeyFactory().setKind("Task");
		}
		
		//addTask("Learn Cloud Datastore Query");
		
		QueryResults<Entity> results = (QueryResults<Entity>) listTasks();
		List<Entity> entities = Lists.newArrayList();
		while (results.hasNext()) {
			Entity result = results.next();
			entities.add(result);
		}
		
		out.println("All task entities in ascending order of creation time:");
		for (Entity e : entities){
			if (e == null)
				continue;
			out.println("<p>");
			out.println("<li>");
			out.println("created time: " + e.getTimestamp("created").toDate());
			// out.println("description:" + e.getValue("description"));
			out.println("; done: " + e.getBoolean("done"));
			out.println("</li>");
			out.println("</p>");
		}
		
		QueryResults<Entity> toDos = (QueryResults<Entity>) doneTasks();
		entities.clear();
		while (toDos.hasNext()) {
			Entity toDo = toDos.next();
			// out.println(result.getKey().getId());
			entities.add(toDo);
		}
		
		out.println("Not Finished Task");
		for (Entity e : entities){
			if (e == null)
				continue;
			out.println("<p>");
			out.println("<li>");
			out.println("created time: " + e.getTimestamp("created").toDate());
			out.println("; description: " + e.getString("description"));
			out.println("</li>");
			out.println("</p>");
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}
	
	Key addTask(String description) {
		  Key key = datastore.allocateId(keyFactory.newKey());
		  Entity task = Entity.newBuilder(key)
		      .set("description", StringValue.newBuilder(description).setExcludeFromIndexes(true).build())
		      .set("created", Timestamp.now())
		      .set("done", false)
		      .build();
		  datastore.put(task);
		  return key;
	}
	
	/**
	 * Returns a list of all task entities in ascending order of creation time.
	 *
	 * @throws DatastoreException if the query fails
	 */
	Iterator<Entity> listTasks() {
	  Query<Entity> query = Query.newEntityQueryBuilder().setKind("Task")
		  // .setFilter(PropertyFilter.eq("done", false)).build();
	      .setOrderBy(OrderBy.asc("created")).build();
	  
	  return datastore.run(query);
	}
	
	private QueryResults<Entity> doneTasks() {
		   Query<Entity> query = Query.newEntityQueryBuilder().setKind("Task")
				   .setFilter(PropertyFilter.eq("done", false))
				   .setOrderBy(OrderBy.desc("created"))
				   .build();
			  
		   return datastore.run(query);
	}

}
