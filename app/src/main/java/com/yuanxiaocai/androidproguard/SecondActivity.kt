package com.yuanxiaocai.androidproguard

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.yuanxiaocai.androidproguard.parcelable.School

class SecondActivity : AppCompatActivity() {

    private val TAG = javaClass.simpleName

    companion object {
        @JvmStatic
        fun  startActivity(context: Context,data:Parcelable?) {
            val intent = Intent(context, SecondActivity::class.java)
            intent.putExtra("data", data)
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_second)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
        val school = intent.getParcelableExtra("data") as School?
        school?.apply {
            Log.i(TAG, "onCreate: name $street")
        }
    }
}