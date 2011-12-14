package com.joefernandez.irrduino.android.remote;

import com.joefernandez.irrduino.android.remote.R.id;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class ViewReportActivity extends Activity {

	TextView reportText;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
        setContentView(R.layout.report);
        
        reportText = (TextView) findViewById(id.report_text);

        //TODO: send the report request
	}
	
    /** Async Task code (for Irrduino Controller requests) */
    public class IrrduinoCommandTask extends HttpCommandTask {
    	
    	private static final String TAG = "IrrduinoServerRequestTask";
    	
        /** The system calls this to perform work in the UI thread and delivers
          * the result from doInBackground() */
        protected void onPostExecute(String result) {
        	if (result != null) {
        		reportText.setText(result);
        	} else {
        		reportText.setText("Error processing command.");
        	}
        }
    }
}
