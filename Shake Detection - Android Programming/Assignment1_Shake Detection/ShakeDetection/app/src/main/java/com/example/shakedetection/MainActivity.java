package com.example.shakedetection;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;

import android.content.Context;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.Environment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import android.hardware.*;

public class MainActivity extends AppCompatActivity {
    private static final String tag = "demo_log";
    public static final String KEY_MESSAGE = "message";
    private SensorManager sensorMgr;
    private Double threshold;
    private EditText shakeThreshold;
    private String sensorDataFile;
    private Context context;
    private BufferedWriter out;
    private long start;

    private final SensorEventListener accelerometerListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent se) {
            // capture accelerations
            double ax = (double)Math.round(se.values[0] * 1000)/1000;
            double ay = (double)Math.round(se.values[1] * 1000)/1000;
            double az = (double)Math.round(se.values[2] * 1000)/1000;
            long finish = System.currentTimeMillis();
            long timeElapsed = (finish - start)/1000;

            Double overallAcc = Math.sqrt(ax*ax + ay*ay + az*az);
            Log.i("Time", String.valueOf(timeElapsed));
            try
            {
                out.append("\n" + timeElapsed +","+ overallAcc );
            }
            catch (IOException e)
            {
                System.out.println("Exception while writing to file");
            }

            String message = threshold != null ? overallAcc > threshold ? "Shake" : "No Shake" : "Enter Threshold!";
            Log.i(tag,threshold + " is the threshold and shake is " + overallAcc + "ax: "+ax+", ay: "+ay+", az: "+az);

            TextView isShake = findViewById(R.id.isShake);
            TextView acc_xyz = findViewById(R.id.acc_xyz);

            // set shake/no shake textview
            isShake.setText(message);

            // set acceleration xyz textview
            acc_xyz.setText(threshold != null ? "ax: "+ax+", ay: "+ay+", az: "+az : "Enter Threshold!");
        }
        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }
    };

    private final SensorEventListener barometerListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent sensorEvent) {
            float[] values = sensorEvent.values;
            TextView airPressure = findViewById(R.id.airPressure);
            Log.i("barometer", "air Pressure:" + values[0]);
            airPressure.setText(String.format("%.3f mbar", values[0]));
            sensorMgr.unregisterListener(barometerListener);
            Log.i("barometer","Barometer stopped");
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int i) {

        }
    };

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        sensorMgr.unregisterListener(barometerListener);
        sensorMgr.unregisterListener(accelerometerListener);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(tag,"On Create");
        setContentView(R.layout.activity_main);
        shakeThreshold = ((EditText) findViewById(R.id.editThreshold));
        //set default 12
        shakeThreshold.setText("12");
        Log.i(tag, "Default threshold set to 12");

        sensorMgr = (SensorManager) getSystemService(SENSOR_SERVICE);

        sensorDataFile = Environment.getExternalStorageDirectory().getPath() + "/accelerometer_data.txt";
//
//        context = getApplicationContext();
    }


    @Override
    protected void onStart() {
        super.onStart();
        Log.i(tag,"On Start");
    }

    public void onStartButtonClick(View view) throws IOException {
        start = System.currentTimeMillis();
        Log.i(tag,"onStartButtonClick");
        Log.i("File", "File will be at "+sensorDataFile);
        try {
            out = new BufferedWriter(new FileWriter(sensorDataFile));
        } catch (IOException e) {
            Log.i("File", "Error while creating new file");
        }

        // capture threshold value
        threshold = shakeThreshold.getText().toString().trim().length() !=0 ? Double.parseDouble(shakeThreshold.getText().toString()) : null;
        // start shake detector listener by initializing sensor Manager

        if (threshold != null) {
            sensorMgr.registerListener(accelerometerListener, sensorMgr.getDefaultSensor(Sensor.TYPE_ACCELEROMETER), SensorManager.SENSOR_DELAY_NORMAL);
            Log.i(tag,"Shake detection started!");
        } else {
            Log.i(tag,"Shake detection could not start as threshold is empty!");
        }
    }

    public void onStopButtonClick(View view) throws IOException {
        Log.i(tag, "onStopButtonClick");
        // stop shake event listener
        sensorMgr.unregisterListener(accelerometerListener);
        try {
            out.close();
            Log.i("File", "Data File is saved at "+sensorDataFile);
        } catch(IOException e) {
            Log.i("File", "Error while closing file");
        }
        // share sensor data file
        // File dataFile = saveFile(sensorDataFile);
        // shareFile(new File(sensorDataFile));
        Log.i(tag, "Shake detection stopped!");
    }

    public void onBarometerClick(View view) {
        Log.i("barometer","onBarometerClick");
       // start air pressure listener
        sensorMgr.registerListener(barometerListener, sensorMgr.getDefaultSensor(Sensor.TYPE_PRESSURE), SensorManager.SENSOR_DELAY_NORMAL);
        Log.i("barometer","Barometer started");
    }

    public void onCameraClick(View view){
        ImageView imgPlaceholder = (ImageView)findViewById(R.id.imageView);

        Intent intent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
        startActivityForResult(intent, 0);
        Log.i("camera","camera started");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(tag,"On Destroy");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.i(tag,"On Stop");
    }

//        private File saveFile(String filepath) throws IOException {
//            File dd = context.getExternalFilesDir("external_files");
//            String tStamp = (new Date()).toString();
//            Log.d("Generated tstamp", tStamp);
//
//            File outFile = new File(dd, "accelerometer_data.txt");
//            outFile.createNewFile();
//            FileOutputStream fOut = new FileOutputStream(outFile);
//
//            fOut.write(filepath.getBytes());
//            fOut.flush();
//            fOut.close();
//            return outFile;
//        }
//        private void shareFile(File fileWithinMyDir) {
//            Intent intentShareFile = new Intent(Intent.ACTION_SEND);
//
//            if (fileWithinMyDir.exists()) {
//                intentShareFile.setType("application/txt");
//                intentShareFile.putExtra(Intent.EXTRA_STREAM, FileProvider.getUriForFile(context,
//                        BuildConfig.APPLICATION_ID + ".provider",
//                        fileWithinMyDir));
//
//                startActivity(Intent.createChooser(intentShareFile, "Share File"));
//            }
//            else {
//                Log.d("file", "File doesn't exist");
//            }
//        }
    }