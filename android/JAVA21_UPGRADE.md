# Java 21 Upgrade — Manual Steps

This project attempted to use the automated Java upgrade tools but they are unavailable (requires a signed-in Copilot account). Below are manual, safe steps you can run on macOS (zsh) to upgrade the Android Gradle build to use Java 21 (LTS).

1) Install JDK 21 (Homebrew)

```bash
brew update
brew install --cask temurin21
```

2) Verify the installed JDK path and set `JAVA_HOME` for your session

```bash
/usr/libexec/java_home -v 21
export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
java -version
```

3) Configure Gradle to use JDK 21 (project-wide)

Replace the placeholder path with the output of `/usr/libexec/java_home -v 21` if necessary. From project root run:

```bash
# Append the resolved path to android/gradle.properties
echo "org.gradle.java.home=$(/usr/libexec/java_home -v 21)" >> android/gradle.properties
```

Or edit `android/gradle.properties` and add a line:

```
org.gradle.java.home=/Library/Java/JavaVirtualMachines/<your-jdk-21>.jdk/Contents/Home
```

4) Set Gradle toolchain / Kotlin target (Kotlin/Gradle Kotlin DSL examples)

- If your project uses Java toolchains (Kotlin DSL `build.gradle.kts`), add or update:

```kotlin
java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(21))
  }
}
```

- For Kotlin compile target in `app/build.gradle.kts` (or module `build.gradle`):

```kotlin
kotlinOptions {
  jvmTarget = "21"
}
```

5) Upgrade Gradle wrapper (if needed)

Java 21 is best supported by newer Gradle versions. Upgrade to Gradle 8.6+ (or the latest stable that your Android Gradle Plugin supports):

```bash
cd android
./gradlew wrapper --gradle-version 8.6
```

6) Check Android Gradle Plugin (AGP) compatibility

- AGP must be compatible with the chosen Gradle version. If you see AGP-related errors, update the AGP `classpath` in `android/build.gradle.kts` (or `android/build.gradle`) to a version that supports the Gradle version you chose.
- Consult AGP release notes for Java compatibility if build fails.

7) Build and test

From the project root:

```bash
cd android
./gradlew --version
./gradlew assembleDebug
```

Fix any compile errors reported. Typical fixes include:
- Update third-party plugin versions.
- Update Kotlin version to support JVM target 21.
- Add `--stacktrace` and `--info` to Gradle commands to get more debug info.

8) If you want me to apply changes

I can: 
- Update `android/gradle.properties` with the resolved path, 
- Add `java { toolchain { ... } }` snippets to `app/build.gradle.kts`, 
- Update Gradle wrapper by running `./gradlew wrapper --gradle-version 8.6`,
but I cannot run the automated `generate_upgrade_plan` tool because it requires a signed-in Copilot account.

If you'd like me to apply these textual edits to the repository now, say "Apply changes" and I'll update the relevant files (I won't run builds without your confirmation).