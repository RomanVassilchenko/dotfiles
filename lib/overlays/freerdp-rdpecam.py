from pathlib import Path


path = Path("channels/rdpecam/client/camera_device_main.c")
text = path.read_text()

old = """
\tif (!initialized)
\t{
\t\tfor (size_t dst = 0; dst < ARRAYSIZE(available); dst++)
\t\t{
\t\t\tconst CAM_MEDIA_FORMAT dstFormat = available[dst];
\t\t\tfor (size_t src = 0; src < ARRAYSIZE(available); src++)
\t\t\t{
\t\t\t\tconst CAM_MEDIA_FORMAT srcFormat = available[src];
\t\t\t\tif (freerdp_video_conversion_supported(ecamToVideoFormat(srcFormat),
\t\t\t\t                                       ecamToVideoFormat(dstFormat)))
\t\t\t\t{
\t\t\t\t\tformats[count++] = (CAM_MEDIA_FORMAT_INFO){ srcFormat, dstFormat };
\t\t\t\t}
\t\t\t}
\t\t}
\t\tinitialized = TRUE;
\t}
"""

new = """
\tif (!initialized)
\t{
\t\tfor (size_t src = 0; src < ARRAYSIZE(available); src++)
\t\t{
\t\t\tconst CAM_MEDIA_FORMAT format = available[src];
\t\t\tif (freerdp_video_conversion_supported(ecamToVideoFormat(format),
\t\t\t                                       ecamToVideoFormat(format)))
\t\t\t{
\t\t\t\tformats[count++] = (CAM_MEDIA_FORMAT_INFO){ format, format };
\t\t\t}
\t\t}

\t\tfor (size_t dst = 0; dst < ARRAYSIZE(available); dst++)
\t\t{
\t\t\tconst CAM_MEDIA_FORMAT dstFormat = available[dst];
\t\t\tfor (size_t src = 0; src < ARRAYSIZE(available); src++)
\t\t\t{
\t\t\t\tconst CAM_MEDIA_FORMAT srcFormat = available[src];
\t\t\t\tif ((srcFormat == dstFormat) ||
\t\t\t\t    !freerdp_video_conversion_supported(ecamToVideoFormat(srcFormat),
\t\t\t\t                                       ecamToVideoFormat(dstFormat)))
\t\t\t\t{
\t\t\t\t\tcontinue;
\t\t\t\t}
\t\t\t\tformats[count++] = (CAM_MEDIA_FORMAT_INFO){ srcFormat, dstFormat };
\t\t\t}
\t\t}
\t\tinitialized = TRUE;
\t}
"""

if old in text:
    path.write_text(text.replace(old, new))
else:
    print("INFO: FreeRDP getSupportedFormats block not found; skipping rdpecam patch")
