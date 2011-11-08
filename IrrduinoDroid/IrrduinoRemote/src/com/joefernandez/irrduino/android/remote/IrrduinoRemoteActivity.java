package com.joefernandez.irrduino.android.remote;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import org.apache.http.util.ByteArrayBuffer;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
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
	
	private static final String CMD_ALL_OFF = "/off";
	private static final String CMD_ZONE_1_ON = "/zone1/ON";
	private static final String CMD_ZONE_2_ON = "/zone2/ON";
	private static final String CMD_ZONE_3_ON = "/zone3/ON";
	private static final String CMD_ZONE_4_ON = "/zone4/ON";
	private static final String CMD_ZONE_5_ON = "/zone5/ON";
	private static final String CMD_ZONE_6_ON = "/zone6/ON";
	private static final String CMD_ZONE_7_ON = "/zone7/ON";
	private static final String CMD_ZONE_8_ON = "/zone8/ON";
	
	private SharedPreferences settings;
	private boolean settingsChanged = true;
	private String controllerAddress;
	
    protected String zoneRunTime = "1";
	protected EditText statusText;
    

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        Spinner spinnerRunTime = (Spinner) findViewById(R.id.spinner_runtimes);
//        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(
//                this, R.array.run_durations, android.R.layout.simple_spinner_item);
//        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//        spinner.setAdapter(adapter);        
        spinnerRunTime.setAdapter(getSpinnerAdapter());
        spinnerRunTime.setOnItemSelectedListener(new RuntimeItemSelectedListener());
        
        statusText = (EditText) findViewById(R.id.status_text);

        Button allOff = (Button) findViewById(R.id.button_all_stop);
        allOff.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + CMD_ALL_OFF);
			}
		});

        Button zone1 = (Button) findViewById(R.id.button_garden);
        zone1.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_1_ON +
	            									"/" + zoneRunTime);
			}
		});
    
        Button zone2 = (Button) findViewById(R.id.button_backyard_lawn_1);
        zone2.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_2_ON +
	            									"/" + zoneRunTime);
			}
		});

        Button zone3 = (Button) findViewById(R.id.button_backyard_lawn_2);
        zone3.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_3_ON +
	            									"/" + zoneRunTime);
			}
		});

        Button zone4 = (Button) findViewById(R.id.button_backyard_lawn_3);
        zone4.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_4_ON +
	            									"/" + zoneRunTime);
			}
		});

        Button zone5 = (Button) findViewById(R.id.button_patio_plants);
        zone5.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_5_ON +
	            									"/" + zoneRunTime);
			}
		});
        
        // Zone 6 (backyard left side flower beds, is not hooked up)
//        Button zone6 = (Button) findViewById(R.id.button_patio_plants);
//        zone6.setOnClickListener(new OnClickListener() {
//			public void onClick(View v) {
//	            new IrrduinoCommandTask().execute(getControllerAddress() + 
//	            									CMD_ZONE_6_ON +
//	            									"/" + zoneRunTime);
//			}
//		});
        
        Button zone7 = (Button) findViewById(R.id.button_frontyard_lawn_1);
        zone7.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_7_ON +
	            									"/" + zoneRunTime);
			}
		});

        Button zone8 = (Button) findViewById(R.id.button_frontyard_lawn_2);
        zone8.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
	            new IrrduinoCommandTask().execute(getControllerAddress() + 
	            									CMD_ZONE_8_ON +
	            									"/" + zoneRunTime);
			}
		});
        
    }

    public String getControllerAddress(){

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
        default:
            return super.onOptionsItemSelected(item);
        }
    }   
	//=== Async Task code (for HTML requests) ============================================
    private class IrrduinoCommandTask extends AsyncTask<String, Void, String> {
        /** The system calls this to perform work in a worker thread and
          * delivers it the parameters given to AsyncTask.execute() */
        protected String doInBackground(String... urls) {
            try {
                URL commandURL = new URL(urls[0]);
                URLConnection conn = commandURL.openConnection();
                InputStream is = conn.getInputStream();
                BufferedInputStream bis = new BufferedInputStream(is);
                ByteArrayBuffer baf = new ByteArrayBuffer(50);

                int current = 0;
                while((current = bis.read()) != -1){
                    baf.append((byte)current);
                }

                /* Convert the Bytes read to a String. */
                return new String(baf.toByteArray());
                
            } catch (Exception e) {
            	Log.d(TAG, "http request exception for: " + urls[0]);
            	Log.d(TAG, "    Exception: "+e.getMessage());
            }
            return null;

        }
        
        /** The system calls this to perform work in the UI thread and delivers
          * the result from doInBackground() */
        protected void onPostExecute(String result) {
        	if (result != null) {
            	statusText.setText(result);
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

		adapter.add(new SpinnerItemData("1 Minute", "1"));
		adapter.add(new SpinnerItemData("2 Minutes", "2"));
		adapter.add(new SpinnerItemData("3 Minutes", "3"));
		adapter.add(new SpinnerItemData("4 Minutes", "4"));
		adapter.add(new SpinnerItemData("5 Minutes", "5"));
		adapter.add(new SpinnerItemData("6 Minutes", "6"));
		adapter.add(new SpinnerItemData("7 Minutes", "7"));
		adapter.add(new SpinnerItemData("8 Minutes", "8"));
		adapter.add(new SpinnerItemData("9 Minutes", "9"));
		adapter.add(new SpinnerItemData("10 Minutes", "10"));
		
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		return adapter;
	}

	public class SpinnerItemData {
		public String key;
		public String value;

		SpinnerItemData(String key, String value){
			this.key = key;
			this.value = value;
		}
		
		@Override
		public String toString(){
			return key;
		}
	}

}

