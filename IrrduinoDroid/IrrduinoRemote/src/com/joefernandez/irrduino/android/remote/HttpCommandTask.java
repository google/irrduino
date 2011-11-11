package com.joefernandez.irrduino.android.remote;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import org.apache.http.util.ByteArrayBuffer;

import android.os.AsyncTask;
import android.util.Log;

/** Async Task code (for Generic HTML requests) 
 * extend this class and add an onPostExecute() method
 * to receive and process the returned string.
 *        
 * <pre>
 * protected void onPostExecute(String result) {
 *     // do something with the result
 * }
 * </pre>
 */
public class HttpCommandTask extends AsyncTask<String, Void, String> {
	
	private static final String TAG = "HttpCommandTask";
	
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

}
