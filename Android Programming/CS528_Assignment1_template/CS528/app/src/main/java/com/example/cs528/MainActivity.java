package com.example.cs528;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;

import android.content.Context;
import android.content.Intent;
import android.hardware.SensorEventListener;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;
import android.hardware.*;

public class MainActivity extends AppCompatActivity implements SensorEventListener {
    private SensorManager mSensorManager;
    private Sensor mLight;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Button button = findViewById(R.id.button);
        TextView txtView = findViewById(R.id.textView);
        mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        mLight = mSensorManager.getDefaultSensor(Sensor.TYPE_LIGHT);
        //mSensorButton = new SensorButton(button, txtView);
        button.setOnClickListener(new SensorButton(button, txtView));
    }
    @Override
    public void onSensorChanged(SensorEvent e){
        float value = e.values[0];
        long tstamp = e.timestamp;
        String out = String.valueOf(tstamp) + "," + String.valueOf(value) + "\n";
        Log.d("Light Sensor", out);

    }
    @Override
    public void onAccuracyChanged(Sensor s, int acc){

    }
    protected void onResume() {
        super.onResume();
        mSensorManager.registerListener(this, mLight, SensorManager.SENSOR_DELAY_NORMAL);
    }

    protected void onPause() {
        super.onPause();
        mSensorManager.unregisterListener(this);
    }

    private class SensorButton implements View.OnClickListener{
        private boolean state = false;
        private Button button;
        private TextView txtView;
        private Context context;
        SensorButton(Button button, TextView txtView){
            this.button = button;
            this.txtView = txtView;
            this.context = getApplicationContext();
        }
        @Override
        public void onClick(View view) {

            if(!state) {
                txtView.setText("Started");
                button.setText("Stop");
                Log.d("Button", "Button started");
                //Sensor collected some data
            }
            else{
                txtView.setText("Stopped");
                button.setText("Start");
                Log.d("Button", "Button stopped");
                String hello = "hello world";
                try {
                    File dataFile = saveFile(hello);
                    shareFile(dataFile);
                }
                catch(IOException e){
                    e.printStackTrace();
                }

            }
            state = !state;

        }
        private File saveFile(String data) throws IOException {
            File dd = context.getExternalFilesDir("external_files");
            String tStamp = (new Date()).toString();
            Log.d("Generated tstamp", tStamp);

            File outFile = new File(dd, tStamp + ".txt");
            outFile.createNewFile();
            FileOutputStream fOut = new FileOutputStream(outFile);

            fOut.write(data.getBytes());
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
            else{
                Log.d("file", "File doesn't exist");
            }
        }
    };
}



