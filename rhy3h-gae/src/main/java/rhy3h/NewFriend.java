package rhy3h;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
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
import com.google.cloud.datastore.FullEntity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.KeyFactory;
import com.google.cloud.datastore.ListValue;
import com.google.cloud.datastore.PathElement;
import com.google.cloud.datastore.Query;
import com.google.cloud.datastore.QueryResults;
import com.google.cloud.datastore.StringValue;
import com.google.cloud.datastore.StructuredQuery.OrderBy;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.common.collect.Lists;

/**
 * Servlet implementation class NewFriend
 */
@WebServlet("/NewFriend")
public class NewFriend extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Datastore datastore;
	private KeyFactory keyFactory;
	
    /**
     * @throws IOException 
     * @throws FileNotFoundException 
     * @see HttpServlet#HttpServlet()
     */
    public NewFriend() throws FileNotFoundException, IOException {
        super();
        // TODO Auto-generated constructor stub
    }
    
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
    }
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
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
		response.setContentType("text/html;charset=UTF-8");
		
		String name = request.getParameter("name");
        String email = request.getParameter("email");
        String type = request.getParameter("type");
        String phone = request.getParameter("phone");
        
        FullEntity<?> newPhone = datastore.get(newPhone(type, phone, name));
        ListValue listPhone = ListValue.of(newPhone);
        AddNewFriend(name, email, listPhone);
        
        response.sendRedirect("ListFriend");
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
