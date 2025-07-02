package com.example.yomi_reader;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import com.worksap.nlp.sudachi.Config;
import com.worksap.nlp.sudachi.PathAnchor;
import com.worksap.nlp.sudachi.Dictionary;
import com.worksap.nlp.sudachi.DictionaryFactory;
import com.worksap.nlp.sudachi.Morpheme;
import com.worksap.nlp.sudachi.Tokenizer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SudachiTokenizer {
    private static Dictionary dictionary;
    private static Tokenizer tokenizer;
    private static final String TAG = "Sudachi";
    private static final String[] DICT_FILES = {"sudachi.json", "system_core.dic", "char.def"};
    private static final String DICT_VERSION = "20250515";

    public static void init(Context context) throws IOException {
        if (dictionary != null) {
            Log.d(TAG, "Sudachi already initialized");
            return;
        }

        Log.d(TAG, "Starting Sudachi initialization");
        File tempDir = new File(context.getCacheDir(), "sudachi");
        if (!tempDir.exists() && !tempDir.mkdirs()) {
            Log.e(TAG, "Failed to create temp directory: " + tempDir.getPath());
            throw new IOException("Failed to create temp directory: " + tempDir.getPath());
        }
        Log.d(TAG, "Temp directory created: " + tempDir.getPath());

        File versionFile = new File(tempDir, "version.txt");
        boolean needsCopy = !versionFile.exists() || !readVersion(versionFile).equals(DICT_VERSION);
        Log.d(TAG, "Needs copy: " + needsCopy);

        if (needsCopy) {
            AssetManager assetManager = context.getAssets();
            Log.d(TAG, "Listing all assets...");
            try {
                String[] assetFiles = assetManager.list("");
                if (assetFiles != null) {
                    for (String file : assetFiles) {
                        Log.d(TAG, "Asset found: " + file);
                        if (file.equals("flutter_assets")) {
                            String[] flutterAssets = assetManager.list("flutter_assets/assets");
                            if (flutterAssets != null) {
                                for (String subFile : flutterAssets) {
                                    Log.d(TAG, "Flutter asset found: flutter_assets/assets/" + subFile);
                                }
                            }
                        }
                    }
                } else {
                    Log.e(TAG, "No files found in assets");
                }
            } catch (IOException e) {
                Log.e(TAG, "Failed to list assets: " + e.getMessage());
            }

            Log.d(TAG, "Copying dictionary files...");
            for (String fileName : DICT_FILES) {
                String assetPath = "flutter_assets/assets/" + fileName;
                Log.d(TAG, "Attempting to copy: " + assetPath);
                File outFile = new File(tempDir, fileName);
                try (InputStream in = assetManager.open(assetPath);
                     FileOutputStream out = new FileOutputStream(outFile)) {
                    byte[] buffer = new byte[1024];
                    int read;
                    int totalBytes = 0;
                    while ((read = in.read(buffer)) != -1) {
                        out.write(buffer, 0, read);
                        totalBytes += read;
                    }
                    Log.d(TAG, "Copied " + fileName + ": " + totalBytes + " bytes");
                } catch (IOException e) {
                    Log.e(TAG, "Failed to copy " + assetPath + ": " + e.getMessage());
                    throw new IOException("Failed to copy " + assetPath + ": " + e.getMessage(), e);
                }
                if (!outFile.exists() || outFile.length() == 0) {
                    Log.e(TAG, "File " + fileName + " not created or empty");
                    throw new IOException("File " + fileName + " not created or empty");
                }
                Log.d(TAG, "File exists: " + fileName + ", size: " + outFile.length());
            }
            try (FileOutputStream out = new FileOutputStream(versionFile)) {
                out.write(DICT_VERSION.getBytes());
                Log.d(TAG, "Version file written: " + DICT_VERSION);
            }
        } else {
            Log.d(TAG, "Checking existing files...");
            for (String fileName : DICT_FILES) {
                File outFile = new File(tempDir, fileName);
                if (!outFile.exists() || outFile.length() == 0) {
                    Log.e(TAG, "File " + fileName + " missing or empty");
                    throw new IOException("File " + fileName + " missing or empty");
                }
                Log.d(TAG, "File exists: " + fileName + ", size: " + outFile.length());
            }
        }

        Log.d(TAG, "Configuring Sudachi...");
        try {
            PathAnchor anchor = PathAnchor.filesystem(Paths.get(tempDir.getPath()));
            Log.d(TAG, "PathAnchor set to: " + tempDir.getPath());
            Config config = Config.fromClasspath("sudachi.json", anchor);
            Log.d(TAG, "Config loaded from sudachi.json");
            dictionary = new DictionaryFactory().create(config);
            Log.d(TAG, "Dictionary created");
            tokenizer = dictionary.create();
            Log.d(TAG, "Tokenizer created");
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize Sudachi: " + e.getMessage(), e);
            throw new IOException("Failed to init Sudachi: " + e.getMessage(), e);
        }
    }

    private static String readVersion(File versionFile) {
        byte[] bytes = new byte[32];
        try (java.io.FileInputStream in = new java.io.FileInputStream(versionFile)) {
            int bytesRead = in.read(bytes);
            return bytesRead > 0 ? new String(bytes, 0, bytesRead) : "";
        } catch (IOException e) {
            Log.e(TAG, "Failed to read version: " + e.getMessage());
            return "";
        }
    }

    public static List<Map<String, String>> tokenize(String text, String mode) {
        if (tokenizer == null) {
            Log.e(TAG, "Tokenizer is null, not initialized");
            return new ArrayList<>();
        }
        Log.d(TAG, "Tokenizing text: " + text + ", mode: " + mode);
        List<Map<String, String>> tokens = new ArrayList<>();
        Tokenizer.SplitMode splitMode;
        switch (mode) {
            case "A":
                splitMode = Tokenizer.SplitMode.A;
                break;
            case "B":
                splitMode = Tokenizer.SplitMode.B;
                break;
            case "C":
            default:
                splitMode = Tokenizer.SplitMode.C;
                break;
        }
        Log.d(TAG, "Using splitMode: " + splitMode);
        List<Morpheme> morphemes = tokenizer.tokenize(splitMode, text);
        for (Morpheme m : morphemes) {
            Map<String, String> token = new HashMap<>();
            token.put("surface", m.surface());
            token.put("reading", m.readingForm());
            token.put("pos", m.partOfSpeech().get(0));
            tokens.add(token);
        }
        Log.d(TAG, "Tokens: " + tokens);
        return tokens;
    }
}