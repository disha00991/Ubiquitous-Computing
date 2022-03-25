package com.example.class_demo;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {
    private static final String tag = "demo_log";
    public static final String KEY_MESSAGE = "message";
    private SensorManager sensorMgr;
    private Integer threshold;
    private EditText shakeThreshold;
    private File sensorDataFile;
    private Context context;
    private sdcard;
    private BufferedWriter out;

    private final SensorEventListener sensorListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent se) {
            // capture accelerations
            float ax = se.values[0];
            float ay = se.values[1];
            float az = se.values[2];
            String tStamp = (new Date()).toString();

            try
            {
                out.append(tStamp +","+ Float.toString(ax) +","+ Float.toString(ay) +","+ Float.toString(az));
            }
            catch (IOException e)
            {
                System.out.println("Exception while writing to file");
            }

            Double overallAcc = Math.sqrt(ax*ax + ay*ay + az*az);

            String message = threshold == -1 ? "Enter Threshold!" : overallAcc > threshold ? "Shake" : "No Shake";
            Log.i(tag,threshold + " is the threshold and shake is " + overallAcc);

            TextView isShake = findViewById(R.id.isShake);
            TextView acc_xyz = findViewById(R.id.acc_xyz);

            // set shake/no shake textview
            isShake.setText(message);

            // set acceleration xyz textview
            acc_xyz.setText(threshold == -1 ? "Enter Threshold!" : "ax: "+ax+", ay: "+ay+", az: "+az);
        }
        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }
    };

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
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

        sdcard = Environment.getExternalStorageDirectory().getPath();

        context = getApplicationContext();
    }


    @Override
    protected void onStart() {
        super.onStart();
        Log.i(tag,"On Start");
    }

    public void onStartButtonClick(View view) {
        Log.i(tag,"onStartButtonClick");
        sensorDataFile = sdcard + "/data_sensor.txt";
        out = new BufferedWriter(new FileWriter(sensorDataFile));
        // capture threshold value
        threshold = shakeThreshold.getText().toString().trim().length() != 0 ? Integer.parseInt(threshold_) : -1;

        // start shake detector listener by initializing sensor Manager
        sensorMgr = (SensorManager) getSystemService(SENSOR_SERVICE);
        sensorMgr.registerListener(sensorListener, sensorMgr.getDefaultSensor(Sensor.TYPE_ACCELEROMETER), SensorManager.SENSOR_DELAY_NORMAL);
        Log.i(tag,"Shake detection started!");
    }

    public void onStopButtonClick(View view) {
        Log.i(tag, "onStopButtonClick");
        // stop shake event listener
        sensorMgr.unregisterListener(sensorListener);
        out.close();
        // share sensor data file
//        try {
//            File dataFile = saveFile(sdcard + "/Accelo.txt");
//            shareFile(dataFile);
//        }
//        catch
//        IOException e){
//            e.printStackTrace();
//        }
        Log.i(tag, "Shake detection stopped!");
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

    private File saveFile(String filepath) throws IOException {
        File dd = context.getExternalFilesDir("external_files");
        String tStamp = (new Date()).toString();
        Log.d("Generated tstamp", tStamp);

        File outFile = new File(dd, tStamp + ".txt");
        outFile.createNewFile();
        FileOutputStream fOut = new FileOutputStream(outFile);

        fOut.write(filepath.getBytes());
        fOut.flush();
        fOut.close();
        return outFile;
    }
    private void shareFile(File fileWithinMyDir) {
        Intent intentShareFile = new Intent(Intent.ACTION_SEND);

        if (fileWithinMyDir.exists()) {
            intentShareFile.setType("application/txt");
            intentShareFile.putExtra(Intent.EXTRA_STREAM, FileProvider.getUriForFile(context,
                    BuildConfig.APPLICATION_ID + ".provider",
                    fileWithinMyDir));

            startActivity(Intent.createChooser(intentShareFile, "Share File"));
        }
        else {
            Log.d("file", "File doesn't exist");
        }
    }
}