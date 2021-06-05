package rhy3h;

import java.io.Serializable;
import java.util.Date;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.cloud.datastore.Key;

public class Message implements Serializable{
	private static final long serialVersionUID = 3L;

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;
	
	@Persistent
	private String author;
	
	@Persistent
	private String title;
	
	@Persistent
	private String content;
	
	@Persistent
	private Date date;
	
	public Message(String author, String title, String content){
		this.author = author;
		this.title = title;
		this.content = content;
		this.date = new Date();
	}
	
	public Key getKey(){
		return key;
	}
	
	public String getAuthor(){
		return author;
	}
	
	public String getTitle(){
		return title;
	}
	
	public String getContent(){
		return content;
	}

	public Date getDate(){
		return date;
	}
}
