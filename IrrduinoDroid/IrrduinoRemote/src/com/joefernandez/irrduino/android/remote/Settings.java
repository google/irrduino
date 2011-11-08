package com.joefernandez.irrduino.android.remote;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class Settings extends PreferenceActivity {

	public static final String CONTROLLER_HOST_NAME = "controller_host_name";
	public static final String CONTROLLER_HOST_PORT = "controller_host_port";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
        // Load the preferences from an XML resource
        addPreferencesFromResource(R.xml.settings);		
	}
}
