# sushi-gakusei
Pattern memory game with sushi


<table style="width: 99%; border-collapse: collapse;">
    <tr>
        <td style="width:30%; text-align: center;">
            <img src="https://img.itch.zone/aW1nLzI2MDQ0MzcwLnBuZw==/180x143%23c/r5J0b2.png" alt="WiPersona" style="max-width: 100%; height: auto;" />
        </td>
        <td style="width: 70%; vertical-align: top;">
            <h1>Sushi Gakusei</h1>
            <h3>by <a href="https://itszariep.itch.io">ItsZariep</a></h3>
            <h4>Pattern game with sushi</h4>
            <div style="margin-top: 20px;">
                <a href="https://itszariep.itch.io/wipersona" style="display: inline-block; background-color: #91a666; color: white; padding: 15px 32px; text-align: center; text-decoration: none; border-radius: 5px;">Play on itch.io</a>
            </div>
        </td>
    </tr>
</table>


# Build 

```
git clone https://github.com/zariep-software/sushi-gakusei
cd sushi-gakusei/src
```

## Desktop
```
dub build
```

## Web
```
git submodule update --init --recursive
dmd -run buildweb/build_web.d
```

## Android

```
git submodule update --init --recursive
abuild/build-android.sh
```
```
cd android
gradle wrapper
ASSETS_OUTPUT=$(realpath app/src/main/assets/assets) abuild/copy-assets.sh
gradlew assembleDebug
```