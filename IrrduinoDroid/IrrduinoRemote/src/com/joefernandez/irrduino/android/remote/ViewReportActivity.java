package com.joefernandez.irrduino.android.remote;

import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.format.DateFormat;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.widget.TextView;

import com.joefernandez.irrduino.android.remote.R.id;

public class ViewReportActivity extends Activity {

	private static final String TAG = "ViewReportActivity";

	// get localized date and time format
	private java.text.DateFormat dateFormat;
	private java.text.DateFormat timeFormat;
	
	private Calendar priorDate = Calendar.getInstance();
	private Calendar nextDate = Calendar.getInstance();
	
	protected String reportServerHostName;
	protected TextView reportText;
	private SharedPreferences settings;
	private boolean settingsChanged = true;

	private final static String REPORT_JSON_FORMAT = "/log?format=json";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
        setContentView(R.layout.report);
        
        reportText = (TextView) findViewById(id.report_text);
        reportText.setMovementMethod(new ScrollingMovementMethod());
    	settingsChanged = true;

    	// get settings
    	settings = PreferenceManager.getDefaultSharedPreferences(this);

    	// set time zone settings and date formatter
		priorDate.setTimeZone(TimeZone.getDefault());
		nextDate.setTimeZone(TimeZone.getDefault());

		dateFormat = DateFormat.getDateFormat(this); // set localized date-only format
		timeFormat = DateFormat.getTimeFormat(this); // set localized time-only format
		
    	
        //send the report request
    	if (settings.getString(Settings.SERVER_HOST_NAME,
				 Settings.DEFAULT_SERVER_HOST).compareTo(Settings.DEFAULT_SERVER_HOST) == 0){
    		// default setting, warn user
        	reportText.setText("Report server is not set,\n specify a server in Settings.");
    	}
    	else{
        	reportText.setText("Requesting report...");
            new IrrduinoServerRequestTask().execute(getReportServerUrl() + REPORT_JSON_FORMAT);
    	}
	}
	
    private String getReportServerUrl(){

    	if (reportServerHostName == null || settingsChanged){
	    	String host = settings.getString(Settings.SERVER_HOST_NAME,
	    									 Settings.DEFAULT_SERVER_HOST);
	    	String port = settings.getString(Settings.SERVER_HOST_PORT,
	    									 Settings.DEFAULT_SERVER_PORT);
	    	
	    	reportServerHostName = "http://"+host;
	    	if (port != null && !port.equalsIgnoreCase("80")){
	    		reportServerHostName += ":"+port;
	    	}
	    	settingsChanged = false;
    	}
    	return reportServerHostName;
    }
    
    protected void parseJsonReport(String reportJson){
    	try {
    		JSONObject response = new JSONObject(reportJson);
    		JSONArray zoneRuns = response.getJSONArray("zone_runs");

    		StringBuffer sb = new StringBuffer();
    		
    		priorDate.setTimeInMillis(zoneRuns.getJSONObject(0).getLong("created_at"));
    		sb.append(formatDate(priorDate.getTimeInMillis())+"\n" );
    		
    		for (int i = 0; i < 16; i++){
    			
    			nextDate.setTimeInMillis(zoneRuns.getJSONObject(i).getLong("created_at"));
    			if (isSameDay(priorDate, nextDate)){
    				// no new header
    			} else {
    	    		sb.append("\n"+formatDate(nextDate.getTimeInMillis())+"\n" );
    	    		priorDate.setTime(nextDate.getTime());
    			}
    			
        		sb.append("Zone "+
        				zoneRuns.getJSONObject(i).getInt("zone"));
        		sb.append(", "+
        				zoneRuns.getJSONObject(i).getInt("runtime_seconds")+
        				  " secs ");
        		sb.append("at "+
        				formatTime(
        						zoneRuns.getJSONObject(i).getLong("created_at"))
        				 );
        		sb.append("\n");
    		}
    		reportText.setText(sb.toString());
    		
    	} catch (JSONException e) {
    		Log.d(TAG, "Unable to parse JSON response: "+ reportJson);
    	}
    }
    
    private boolean isSameDay(Calendar cal1, Calendar cal2){
    	return 	cal1.get(Calendar.YEAR) == cal2.get(Calendar.YEAR) &&
        		cal1.get(Calendar.DAY_OF_YEAR) == cal2.get(Calendar.DAY_OF_YEAR);
    }
    
    private String formatDate(long time){
    	return dateFormat.format(new Date(time));
    }
    private String formatTime(long time){
    	return timeFormat.format(new Date(time));
    }
    
    @Override
	protected void onResume() {
		super.onResume();
    	// refresh settings
    	settings = PreferenceManager.getDefaultSharedPreferences(this);
	}

	/** Async Task code (for web requests) */
    public class IrrduinoServerRequestTask extends HttpCommandTask {
    	
    	private static final String TAG = "IrrduinoServerRequestTask";
    	
        /** The system calls this to perform work in the UI thread and delivers
          * the result from doInBackground() */
        protected void onPostExecute(String result) {
        	if (result != null) {
        		parseJsonReport(result);
        		//reportText.setText(result);
        	} else {
        		reportText.setText("Error processing command.");
        	}
        }
    }
}
