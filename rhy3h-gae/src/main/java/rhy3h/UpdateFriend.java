package rhy3h;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
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
import com.google.cloud.datastore.PathElement;
import com.google.cloud.datastore.Transaction;
import com.google.cloud.datastore.Value;
import com.google.common.collect.Lists;

/**
 * Servlet implementation class UpdateFriend
 */
@WebServlet("/UpdateFriend")
public class UpdateFriend extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Datastore datastore;
	private KeyFactory keyFactory;
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UpdateFriend() {
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
			//String jsonPath = "/Users/rhy3h/Dropbox/Documents/rhy3h-gae-4846cd370532.json";
			String jsonPath = "C:\\Users\\rhy3h\\Dropbox\\Documents\\rhy3h-gae-4846cd370532.json";
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
		
		String name = request.getParameter("name");
        String email = request.getParameter("email");
        String type = request.getParameter("type");
        String phone = request.getParameter("phone");
        
        if(updateFriend(name, email, type, phone)) {
        	response.sendRedirect("ListFriend");
        }
	}
	
	boolean updateFriend(String _name, String _email, String _type, String _phone) {
		Transaction transcation = datastore.newTransaction();
		try {
			Entity friend = transcation.get(keyFactory.newKey(_name));
			if(friend != null) {
				if(!_phone.equals("")) {
					ListValue phones = ((ListValue) friend.getValue("phone"));
					List<? extends Value<?>> list = phones.get();
					ListValue.Builder builder = ListValue.newBuilder();
					for(Value<?> item : list) {
						FullEntity<?> phoneEntity = ((EntityValue) item).get();
						if(!phoneEntity.getString("type").equals(_type))
							builder.addValue(phoneEntity);
					}
					Entity e = datastore.get(updatePhone(_type, _phone, _name));
					transcation.update(
							Entity.newBuilder(friend)
							.set("phone", builder.addValue(e).build())
							.build()
					);
				}
				if(!_email.equals("")) {
					transcation.update(Entity.newBuilder(friend).set("email", _email).build());
				}
				
			}
			transcation.commit();
			return friend != null;
		} finally {
			if(transcation.isActive()) {
				transcation.rollback();
			}
		}
	}

	Key updatePhone(String type, String num, String name) {
		KeyFactory ketFactory2 = datastore.newKeyFactory()
				.addAncestor(PathElement.of("Friend", name))
				.setKind("Phone");
		Key key = ketFactory2.newKey(name + "_" + type);
		
		Entity phone = Entity.newBuilder(key)
				.set("type", type)
				.set("number", num)
				.set("name", name)
				.build();
		datastore.put(phone);
		
		return key;
	}
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
