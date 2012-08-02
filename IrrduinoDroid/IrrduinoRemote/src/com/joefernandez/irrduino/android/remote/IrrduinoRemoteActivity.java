/*
 * Copyright 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.joefernandez.irrduino.android.remote;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.joefernandez.irrduino.android.remote.ViewReportActivity.IrrduinoServerRequestTask;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

public class IrrduinoRemoteActivity extends Activity {
	
	private static final String TAG = "IrrduinoRemoteActivity";
	
	private static final String CMD_ALL_OFF 	= "/off";
	private static final String CMD_ZONE_PREFIX = "/zone";
	private static final String CMD_ON 			= "/ON";
	private static final String CMD_STATUS 		= "/status";
	
	private static final int ZONE_GARDEN 		= 1;
	private static final int ZONE_BACK_LAWN1 	= 2;
	private static final int ZONE_BACK_LAWN2 	= 3;
	private static final int ZONE_BACK_LAWN3 	= 4;
	private static final int ZONE_PATIO 		= 5;
	private static final int ZONE_FLOWER_BED 	= 6;
	private static final int ZONE_FRONT_LAWN1 	= 7;
	private static final int ZONE_FRONT_LAWN2 	= 8;
	
	private SharedPreferences settings;
	private boolean settingsChanged = true;
	private String controllerAddress;
	
    protected int zoneRunTime = 1;
	protected EditText statusText;
    
	protected CountDownTimer timer;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        Spinner spinnerRunTime = (Spinner) findViewById(R.id.spinner_runtimes);
        spinnerRunTime.setAdapter(getSpinnerAdapter());
        spinnerRunTime.setOnItemSelectedListener(new RuntimeItemSelectedListener());

        statusText = (EditText) findViewById(R.id.status_text);
        
        Bundle extras = getIntent().getExtras(); 
        if(extras !=null) {
            String value = extras.getString("taskResult");
            if (value != null && value.length() > 0){
            	statusText.setText(value);
            }
        }
        

        Button allOff = (Button) findViewById(R.id.button_all_stop);
        allOff.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				statusText.setText("Sending...");
	            new IrrduinoCommandTask().execute(getControllerAddress() + CMD_ALL_OFF);
			}
		});

        Button zone1 = (Button) findViewById(R.id.button_garden);
        zone1.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_GARDEN, zoneRunTime);
			}
		});
    
        Button zone2 = (Button) findViewById(R.id.button_backyard_lawn_1);
        zone2.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_BACK_LAWN1, zoneRunTime);
			}
		});

        Button zone3 = (Button) findViewById(R.id.button_backyard_lawn_2);
        zone3.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_BACK_LAWN2, zoneRunTime);
			}
		});

        Button zone4 = (Button) findViewById(R.id.button_backyard_lawn_3);
        zone4.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_BACK_LAWN3, zoneRunTime);
			}
		});

        Button zone5 = (Button) findViewById(R.id.button_patio_plants);
        zone5.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_PATIO, zoneRunTime);
			}
		});
        
        // Zone 6 (backyard left side flower beds, is not hooked up)
//        Button zone6 = (Button) findViewById(R.id.button_patio_plants);
//        zone6.setOnClickListener(new OnClickListener() {
//			public void onClick(View v) {
//				sendZoneRunCommand(ZONE_FLOWER_BED, zoneRunTime);
//			}
//		});
        
        Button zone7 = (Button) findViewById(R.id.button_frontyard_lawn_1);
        zone7.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_FRONT_LAWN1, zoneRunTime);
			}
		});

        Button zone8 = (Button) findViewById(R.id.button_frontyard_lawn_2);
        zone8.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				sendZoneRunCommand(ZONE_FRONT_LAWN2, zoneRunTime);
			}
		});
        
        // Request global status from controller (run *last*)
        requestSystemStatus();
    }

    @Override
	protected void onResume() {
		super.onResume();
        // Request global status from controller
        requestSystemStatus();
	}



	private void requestSystemStatus(){
    	
    	// get settings
    	settings = PreferenceManager.getDefaultSharedPreferences(this);

    	if (settings.getString(Settings.CONTROLLER_HOST_NAME,
				 Settings.DEFAULT_CONTROLLER_HOST).compareTo(Settings.DEFAULT_CONTROLLER_HOST) == 0){
	   		// default setting, warn user
    		statusText.setText("Report server is not set,\n specify a server in Settings.");
	   	}
	   	else{
	   		statusText.setText("Requesting status...");
	        new IrrduinoCommandTask().execute(getControllerAddress() + CMD_STATUS);
	   	}
   	}
    
    
    private void sendZoneRunCommand(int zone, int minutes){
		statusText.setText("Sending...");
        IrrduinoZoneRunTask zrt =  new IrrduinoZoneRunTask(zone, minutes);
        // command format: http://myirrduinocontroller.com/zone3/ON/1
        zrt.execute(getControllerAddress() + CMD_ZONE_PREFIX +
        			zone + CMD_ON + "/" + minutes);
    }
    
    private String getControllerAddress(){

    	if (controllerAddress == null || settingsChanged){
	    	settings = PreferenceManager.getDefaultSharedPreferences(this);
	    	String host = settings.getString(Settings.CONTROLLER_HOST_NAME, 
	    									 Settings.DEFAULT_CONTROLLER_HOST);
	    	String port = settings.getString(Settings.CONTROLLER_HOST_PORT, 
	    									 Settings.DEFAULT_CONTROLLER_PORT);
	    	
	    	controllerAddress = "http://"+host;
	    	if (port != null && !port.equalsIgnoreCase("80")){
	    		controllerAddress += ":"+port;
	    	}
	    	settingsChanged = false;
    	}
    	return controllerAddress;
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.app_menu, menu);
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	final Intent intent;
        // Handle item selection
        switch (item.getItemId()) {
        case R.id.preferences:
        	intent = new Intent(this, Settings.class);
        	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        	startActivity(intent);
        	settingsChanged = true;
            return true;
        case R.id.report:
        	intent = new Intent(this, ViewReportActivity.class);
        	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        	startActivity(intent);
            return true;
        default:
            return super.onOptionsItemSelected(item);
        }
    }   

    protected String parseJsonStatus(String statusJson){
    	try {
    		JSONObject response = new JSONObject(statusJson);

    		if (response.has("zones")) {
    			return "Zones: " + response.getString("zones");
    		}
    		if (response.has("system status")){ 
    			return "System: "+response.getString("system status");
    		}
		} 
    	catch (JSONException e) {
			Log.d(TAG, "Unable to parse JSON response: "+ statusJson);
			return "System: Not available";
		}
    	return "System: No information";
    }
    		

    /** Async Task code (for Irrduino Controller requests) */
    public class IrrduinoCommandTask extends HttpCommandTask {
    	
    	private static final String TAG = "IrrduinoCommandTask";
    	
        /** The system calls this to perform work in the UI thread and delivers
          * the result from doInBackground() */
        protected void onPostExecute(String result) {
        	if (result != null) {
        		if (timer != null) {
        			timer.cancel();
        		}
        		if (result.length() < 256) {
	            	statusText.setText(parseJsonStatus(result));
        		} else {
        			// something went wrong with the request. Log it.
        			Log.d(TAG, "Error processing command. Unexpected return result:\n" + result);
            		statusText.setText("Error processing command.");
        		}
        	} else {
        		statusText.setText("Error processing command.");
        	}
        }
    }
    
    /** Async Task code (for Irrduino Controller requests) */
    public class IrrduinoZoneRunTask extends HttpCommandTask {
    	
    	private static final String TAG = "IrrduinoZoneRunTask";
    	
    	public int zone = 0;
    	public int minutes = 1;
    	
    	public IrrduinoZoneRunTask(int zone, int minutes){
    		this.zone = zone;
    		this.minutes = minutes;
    	}
    	
        /** The system calls this to perform work in the UI thread and delivers
          * the result from doInBackground() */
        protected void onPostExecute(String result) {
        	if (result != null) {
            	// statusText.setText(result);
        		if (timer != null) {
        			timer.onFinish();
        		}
            	 timer = new CountDownTimer(60000 * minutes, 1000) {

            	     public void onTick(long millisUntilFinished) {
            	    	 statusText.setText("Running Zone " + zone + ": "+ millisUntilFinished / 1000);
            	     }

            	     public void onFinish() {
            	    	 statusText.setText("Zone " + zone + ": OFF");
            	     }
            	  }.start();            	
        	} else {
        		statusText.setText("Error processing command.");
        	}
        }
    }
    
    //=== Duration Spinner management functions ===================================================

    public class RuntimeItemSelectedListener implements OnItemSelectedListener {

        public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
        	zoneRunTime = ((SpinnerItemData) parent.getItemAtPosition(pos)).value;
        }

        public void onNothingSelected(AdapterView parent) {
        	// Do nothing.
        }
    }
    
	public ArrayAdapter<SpinnerItemData> getSpinnerAdapter(){
		ArrayAdapter<SpinnerItemData> adapter = 
			new ArrayAdapter<SpinnerItemData>( 
			this,
			android.R.layout.simple_spinner_item);

		adapter.add(new SpinnerItemData("1 Minute",    1));
		adapter.add(new SpinnerItemData("2 Minutes",   2));
		adapter.add(new SpinnerItemData("3 Minutes",   3));
		adapter.add(new SpinnerItemData("4 Minutes",   4));
		adapter.add(new SpinnerItemData("5 Minutes",   5));
		adapter.add(new SpinnerItemData("6 Minutes",   6));
		adapter.add(new SpinnerItemData("7 Minutes",   7));
		adapter.add(new SpinnerItemData("8 Minutes",   8));
		adapter.add(new SpinnerItemData("9 Minutes",   9));
		adapter.add(new SpinnerItemData("10 Minutes", 10));
		
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		return adapter;
	}

	public class SpinnerItemData {
		public String key;
		public int value;

		SpinnerItemData(String key, int value){
			this.key = key;
			this.value = value;
		}
		
		@Override
		public String toString(){
			return key;
		}
	}

}

