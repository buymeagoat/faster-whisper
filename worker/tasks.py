from celery import Celery
from faster_whisper import WhisperModel
from datetime import datetime
import os, json, logging

app = Celery("tasks", broker=os.getenv("REDIS_URL", "redis://localhost:6379/0"))

model = WhisperModel(
    "./models/faster-whisper-large-v3",
    local_files_only=True
)

# Logging setup
os.makedirs("logs", exist_ok=True)
log_path = f"logs/celery_{datetime.utcnow().strftime('%Y%m%d')}.log"
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(log_path, encoding="utf-8"),
        logging.StreamHandler()
    ]
)
log = logging.getLogger(__name__)

@app.task
def transcribe(job_id, path):
    start_time = datetime.utcnow()
    log.info(f"🟢 START: {job_id}")
    log.info(f"📥 File: {path}")

    try:
        segments, info = model.transcribe(path, beam_size=5, language="en")
        os.makedirs("outputs", exist_ok=True)

        txt_path = f"outputs/{job_id}.txt"
        meta_path = f"outputs/{job_id}.json"

        with open(txt_path, "w", encoding="utf-8") as f:
            for s in segments:
                f.write(s.text.strip() + "\n")

        metadata = {
            "job_id": job_id,
            "started_utc": start_time.isoformat(),
            "finished_utc": datetime.utcnow().isoformat(),
            "input_file": path,
            "output_file": txt_path,
            "language": info.language,
            "duration_sec": info.duration,
            "segment_count": len(segments)
        }
        with open(meta_path, "w", encoding="utf-8") as mf:
            json.dump(metadata, mf, indent=2)

        log.info(f"🧠 {len(segments)} segments | Lang: {info.language} | Dur: {info.duration:.2f}s")
        for i, s in enumerate(segments[:3]):
            log.info(f"  ▶ [{s.start:.1f}s] {s.text.strip()}")
        log.info(f"✅ DONE: {txt_path}")

    except Exception as e:
        log.error(f"❌ FAILED: {job_id}")
        log.exception(e)
