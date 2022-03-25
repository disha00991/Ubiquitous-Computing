package com.example.class_demo;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.EditText;
import android.widget.TextView;

public class Second_activity extends AppCompatActivity {
    private static final String tag = "demo_second_log";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_second_activity);
        Intent intent = getIntent();
        String message = intent.getStringExtra(MainActivity.KEY_MESSAGE);

        TextView isShake = findViewById(R.id.isShake);

        isShake.setText(message);
        Log.i(tag,"Button click3");
    }
}