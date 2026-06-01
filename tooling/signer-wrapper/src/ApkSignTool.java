import com.android.apksig.ApkSigner;

import java.io.File;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public final class ApkSignTool {
  public static void main(String[] args) throws Exception {
    Config config = Config.parse(args);

    KeyStore keyStore = loadKeyStore(config.keystorePath, config.storePassword);
    PrivateKey privateKey =
        (PrivateKey) keyStore.getKey(config.alias, config.keyPassword.toCharArray());
    if (privateKey == null) {
      throw new IllegalStateException("Alias not found or key password invalid: " + config.alias);
    }

    Certificate[] chain = keyStore.getCertificateChain(config.alias);
    if (chain == null || chain.length == 0) {
      throw new IllegalStateException("Certificate chain not found for alias: " + config.alias);
    }

    List<X509Certificate> certificates = new ArrayList<>();
    for (Certificate certificate : chain) {
      certificates.add((X509Certificate) certificate);
    }

    ApkSigner.SignerConfig signerConfig =
        new ApkSigner.SignerConfig.Builder(config.alias, privateKey, certificates).build();

    ApkSigner.Builder builder =
        new ApkSigner.Builder(Collections.singletonList(signerConfig))
            .setInputApk(new File(config.inputApk))
            .setOutputApk(new File(config.outputApk))
            .setCreatedBy("AndroidTools")
            .setV1SigningEnabled(config.enableV1)
            .setV2SigningEnabled(config.enableV2)
            .setV3SigningEnabled(config.enableV3)
            .setV4SigningEnabled(config.enableV4);

    builder.build().sign();
    System.out.println("SIGN_SUCCESS:" + config.outputApk);
  }

  private static KeyStore loadKeyStore(String keystorePath, String password) throws Exception {
    KeyStore keyStore = KeyStore.getInstance(inferStoreType(keystorePath));
    try (java.io.FileInputStream inputStream = new java.io.FileInputStream(keystorePath)) {
      keyStore.load(inputStream, password.toCharArray());
    }
    return keyStore;
  }

  private static String inferStoreType(String keystorePath) {
    String lower = keystorePath.toLowerCase();
    if (lower.endsWith(".p12") || lower.endsWith(".pfx")) {
      return "PKCS12";
    }
    return "JKS";
  }

  private static final class Config {
    final String inputApk;
    final String outputApk;
    final String keystorePath;
    final String alias;
    final String storePassword;
    final String keyPassword;
    final boolean enableV1;
    final boolean enableV2;
    final boolean enableV3;
    final boolean enableV4;

    Config(
        String inputApk,
        String outputApk,
        String keystorePath,
        String alias,
        String storePassword,
        String keyPassword,
        boolean enableV1,
        boolean enableV2,
        boolean enableV3,
        boolean enableV4) {
      this.inputApk = inputApk;
      this.outputApk = outputApk;
      this.keystorePath = keystorePath;
      this.alias = alias;
      this.storePassword = storePassword;
      this.keyPassword = keyPassword;
      this.enableV1 = enableV1;
      this.enableV2 = enableV2;
      this.enableV3 = enableV3;
      this.enableV4 = enableV4;
    }

    static Config parse(String[] args) {
      String inputApk = null;
      String outputApk = null;
      String keystorePath = null;
      String alias = null;
      String storePassword = null;
      String keyPassword = null;
      boolean enableV1 = true;
      boolean enableV2 = false;
      boolean enableV3 = false;
      boolean enableV4 = false;

      for (int i = 0; i < args.length; i += 2) {
        String key = args[i];
        String value = i + 1 < args.length ? args[i + 1] : "";
        switch (key) {
          case "--input":
            inputApk = value;
            break;
          case "--output":
            outputApk = value;
            break;
          case "--keystore":
            keystorePath = value;
            break;
          case "--alias":
            alias = value;
            break;
          case "--store-pass":
            storePassword = value;
            break;
          case "--key-pass":
            keyPassword = value;
            break;
          case "--enable-v1":
            enableV1 = Boolean.parseBoolean(value);
            break;
          case "--enable-v2":
            enableV2 = Boolean.parseBoolean(value);
            break;
          case "--enable-v3":
            enableV3 = Boolean.parseBoolean(value);
            break;
          case "--enable-v4":
            enableV4 = Boolean.parseBoolean(value);
            break;
          default:
            throw new IllegalArgumentException("Unknown argument: " + key);
        }
      }

      if (inputApk == null
          || outputApk == null
          || keystorePath == null
          || alias == null
          || storePassword == null) {
        throw new IllegalArgumentException("Missing required arguments");
      }

      if (keyPassword == null || keyPassword.isEmpty()) {
        keyPassword = storePassword;
      }

      return new Config(
          inputApk,
          outputApk,
          keystorePath,
          alias,
          storePassword,
          keyPassword,
          enableV1,
          enableV2,
          enableV3,
          enableV4);
    }
  }
}
