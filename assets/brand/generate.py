#!/usr/bin/env python
"""Generate a 40-pose CalorieBuddy mascot library via fal Ideogram V3
generate-transparent (native transparent PNGs, no rembg).

Consistency: a fixed detailed character description (CHAR) + expand_prompt=False.
Distinctness: a vivid per-pose action + a distinct seed per pose.

Writes each as `mascot-<key>.imageset` into the asset catalog and a manifest
(assets/brand/manifest.json) used by the verification workflow.

Reads the fal key from FAL_KEY env var.
"""

import os, io, json, time, urllib.request, threading
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

KEY = os.environ["FAL_KEY"]
URL = "https://fal.run/fal-ai/ideogram/v3/generate-transparent"
HDR = {"Authorization": f"Key {KEY}", "Content-Type": "application/json"}
HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.normpath(os.path.join(HERE, "..", "..", "CalorieBuddy", "Assets.xcassets"))
BASE_SEED = 20260621

CHAR = (
    "a cute chibi cartoon fox mascot named Pip: rounded chunky body, warm orange fur, a large cream-colored "
    "belly patch, cream cheeks and muzzle, a big fluffy tail with a cream tip, big round friendly dark eyes "
    "with white highlights, small triangular ears with cream inner ears, a tiny dark nose, bold clean "
    "dark-brown outlines, flat modern vector illustration with soft cel shading, bright cheerful colors"
)
ISOLATE = ", centered, isolated subject on a fully transparent background, no background, no shadow, sticker style"
NEG = "background, scenery, shadow, ground, floor, frame, border, text, watermark, multiple characters, realistic, photo, blurry"

# (key, vivid action, what a verifier should clearly see)
CONCEPTS = [
    ("happy", "smiling warmly and waving one paw hello", "a happy fox waving"),
    ("excited", "jumping joyfully with both arms raised high and a big open grin", "an excited jumping fox"),
    ("proud", "standing proudly with paws on hips, chest out, confident smile", "a proud confident fox, paws on hips"),
    ("sad", "with a sad teary expression, drooping ears and a frown, looking down", "a sad fox with drooping ears"),
    ("sleeping", "curled up cozily asleep with eyes closed, a small zzz floating nearby", "a fox curled up asleep"),
    ("hungry", "holding a small bowl of food and licking its lips happily", "a hungry fox holding a food bowl"),
    ("love", "with big sparkling heart-shaped eyes, holding a red heart", "a fox in love holding a heart"),
    ("wink", "winking one eye and giving a cheerful thumbs up", "a winking fox with a thumbs up"),
    ("cool", "wearing cool sunglasses with a relaxed confident smirk", "a cool fox wearing sunglasses"),
    ("surprised", "with a shocked surprised face, wide eyes and open mouth, paws on cheeks", "a surprised shocked fox"),
    ("thinking", "with one paw on its chin looking up thoughtfully, a thought bubble", "a thinking fox, paw on chin"),
    ("crying", "crying with big tears streaming down and an upset expression", "a crying fox with tears"),
    ("laughing", "laughing happily with eyes closed, head tilted back, big open smile", "a laughing fox"),
    ("confused", "tilting its head with a confused puzzled look and a question mark", "a confused fox with a question mark"),
    ("determined", "looking determined and fired up wearing a sporty headband, fists clenched", "a determined fox with a headband"),
    ("shy", "shy and blushing with paws held together, looking away bashfully", "a shy blushing fox"),
    ("angry", "looking grumpy and angry with a furrowed brow and arms crossed", "an angry grumpy fox, arms crossed"),
    ("worried", "looking worried and nervous, biting one claw, anxious expression", "a worried nervous fox"),
    ("celebrating", "celebrating with both fists in the air and colorful confetti around it", "a celebrating fox with confetti"),
    ("waving", "giving a big enthusiastic two-paw hello wave with a friendly smile", "a fox waving with both paws"),
    ("drinking-water", "happily drinking from a tall glass of water with a straw", "a fox drinking a glass of water"),
    ("eating-salad", "eating a healthy green salad from a bowl with a fork", "a fox eating a salad"),
    ("running", "jogging and running energetically mid-stride, sporty and active", "a fox running / jogging"),
    ("weighing", "standing on a bathroom weighing scale looking down at it", "a fox standing on a scale"),
    ("meditating", "sitting cross-legged in a calm meditation pose with eyes closed", "a fox meditating cross-legged"),
    ("scanning", "holding up a smartphone taking a photo of a plate of food", "a fox photographing food with a phone"),
    ("cooking", "wearing a chef hat and cooking happily with a frying pan", "a fox chef cooking"),
    ("trophy", "proudly holding up a shiny golden trophy with both paws", "a fox holding a trophy"),
    ("fire-streak", "looking pumped next to a big bright flame, streak energy", "a fox with a flame / fire"),
    ("strong", "flexing its arm muscles proudly, strong and fit", "a fox flexing muscles"),
    ("coffee", "holding a warm cup of coffee with steam and a cozy smile", "a fox holding a coffee cup"),
    ("measuring", "wrapping a yellow measuring tape around its waist", "a fox with a measuring tape on its waist"),
    ("apple", "holding a shiny red apple and smiling, a healthy snack", "a fox holding a red apple"),
    ("no-junk", "pushing away a plate of junk food with a stop gesture, refusing it", "a fox refusing junk food"),
    ("thumbs-up", "giving a big confident double thumbs up with an approving smile", "a fox giving thumbs up"),
    ("pointing", "pointing forward encouragingly like a friendly coach", "a fox pointing forward"),
    ("calendar", "holding a calendar and pointing at a date, planning ahead", "a fox holding a calendar"),
    ("target", "standing next to a bullseye target with an arrow in the center", "a fox next to a bullseye target"),
    ("stretching", "doing a gentle yoga stretch with arms up, relaxed and flexible", "a fox stretching / doing yoga"),
    ("phone", "happily looking at a smartphone app and tapping the screen", "a fox looking at a phone app"),
]

_print_lock = threading.Lock()


def log(*a):
    with _print_lock:
        print(*a, flush=True)


def generate(idx, key, action):
    payload = {
        "prompt": CHAR + ", " + action + ISOLATE,
        "negative_prompt": NEG,
        "aspect_ratio": "1:1",
        "rendering_speed": "QUALITY",
        "expand_prompt": False,
        "seed": BASE_SEED + idx * 17,
        "num_images": 1,
    }
    for attempt in range(3):
        try:
            req = urllib.request.Request(URL, data=json.dumps(payload).encode(), headers=HDR, method="POST")
            with urllib.request.urlopen(req, timeout=200) as r:
                resp = json.loads(r.read().decode())
            url = resp["images"][0]["url"]
            with urllib.request.urlopen(url, timeout=200) as r:
                img = Image.open(io.BytesIO(r.read())).convert("RGBA")
            bbox = img.getbbox()
            if bbox:
                img = img.crop(bbox)
            img.thumbnail((512, 512), Image.LANCZOS)
            name = f"mascot-{key}"
            d = os.path.join(ASSETS, f"{name}.imageset")
            os.makedirs(d, exist_ok=True)
            img.save(os.path.join(d, f"{name}.png"))
            json.dump({"images": [{"filename": f"{name}.png", "idiom": "universal"}], "info": {"author": "xcode", "version": 1}},
                      open(os.path.join(d, "Contents.json"), "w"), indent=2)
            log(f"  [{idx+1:>2}/40] {key} OK")
            return True
        except Exception as e:
            log(f"  [{idx+1:>2}/40] {key} attempt {attempt+1} failed: {e}")
            time.sleep(4)
    return False


def main():
    manifest = [{"key": k, "asset": f"mascot-{k}", "expected": exp} for (k, _a, exp) in CONCEPTS]
    json.dump(manifest, open(os.path.join(HERE, "manifest.json"), "w"), indent=2)

    results = {}
    with ThreadPoolExecutor(max_workers=6) as ex:
        futs = {ex.submit(generate, i, k, a): k for i, (k, a, _e) in enumerate(CONCEPTS)}
        for f in futs:
            results[futs[f]] = f.result()
    ok = sum(1 for v in results.values() if v)
    log(f"DONE: {ok}/{len(CONCEPTS)} generated")
    failed = [k for k, v in results.items() if not v]
    if failed:
        log("FAILED: " + ", ".join(failed))


if __name__ == "__main__":
    main()
