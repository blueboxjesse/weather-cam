#!/usr/bin/env python

# upload.py
#
# Bulk uploads files to SoftLayer object storage.
#
# Use UPLOAD_SLEEP=0 to skip the sleep at the beginning of the batch routine.

import os
from os.path import isfile, join
import time
import swiftclient
from Queue import Queue
from threading import Thread
import mimetypes

# Configuration
MEMORY_STORAGE = "/var/tmp"
HOME_DIR = os.path.expanduser("~")
RESIDENT_STORAGE = HOME_DIR + "/weather-cam-tmp"
BUCKET = os.environ.get("BUCKET") or time.strftime("%Y-%j")
UPLOAD_SLEEP = os.environ.get("UPLOAD_SLEEP") or 60
DATE_STAMP = time.strftime("%Y-%m-%d-%H-%M-%S")
NUM_WORKER_THREADS=10

SWIFT_CONN = swiftclient.client.Connection(
  authurl = os.environ.get('OS_AUTH_URL'),
  key = os.environ.get('OS_PASSWORD'),
  auth_version = os.environ.get('OS_AUTH_VERSION'),
  os_options = {
    'project_id': os.environ.get('OS_PROJECT_ID'),
    'user_id': os.environ.get('OS_USER_ID'),
    'region_name': os.environ.get('OS_REGION_NAME'),
  })
print "*** Swift Connection initialized..."

# Methods
def upload_image(file):
  try:
    mime_type = mimetypes.guess_type(file)[0]
    full_path = join(RESIDENT_STORAGE, BUCKET, file)
    with open(full_path) as file_contents:
      swift_bucket = 'weather-cam-' + BUCKET
      SWIFT_CONN.put_object(swift_bucket, file, file_contents, content_type = mime_type)
      os.remove(full_path)
      return True
  except swiftclient.exceptions.ClientException as (error_string):
    print error_string
  return False
  
def image_worker(i, queue):
  while True:
    print 'Worker %s: Looking for next file' % i
    file = queue.get()
    print 'Worker %s: Initiating upload of' % i, file
    upload_image(file)
    queue.task_done()

print "*** Sleeping for", UPLOAD_SLEEP, "seconds. Override with UPLOAD_SLEEP environment variable."
time.sleep(UPLOAD_SLEEP) # Wait until last photo has been taken and saved locally.
  
image_queue = Queue()  

for i in range(NUM_WORKER_THREADS):
  worker = Thread(target=image_worker, args=(i, image_queue))
  worker.daemon = True
  worker.start()

pending_upload = os.listdir(join(RESIDENT_STORAGE, BUCKET))
for file in pending_upload:
  image_queue.put(file)
  
print "*** Main thread is waiting for children threads to finish..."
image_queue.join()
print "*** All jobs complete..."
