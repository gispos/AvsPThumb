unit avisynth;

//*************************
// Avisynth+ Interface v6
// GPo 2019
//*************************

{$ALIGN 8}
{$Z4}
{$MINENUMSIZE 4}

interface
uses windows;

const
  AVISYNTH_INTERFACE_VERSION = 6;
  AVS_FRAME_ALIGN = 64;

  AVS_SAMPLE_INT8  = 1 shl 0;
  AVS_SAMPLE_INT16 = 1 shl 1;
  AVS_SAMPLE_INT24 = 1 shl 2;
  AVS_SAMPLE_INT32 = 1 shl 3;
  AVS_SAMPLE_FLOAT = 1 shl 4;

  AVS_PLANAR_Y = 1 shl 0;
  AVS_PLANAR_U = 1 shl 1;
  AVS_PLANAR_V = 1 shl 2;
  AVS_PLANAR_ALIGNED = 1 shl 3;
  AVS_PLANAR_Y_ALIGNED = AVS_PLANAR_Y or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_U_ALIGNED = AVS_PLANAR_U or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_V_ALIGNED = AVS_PLANAR_V or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_A = 1 shl 4;
  AVS_PLANAR_R = 1 shl 5;
  AVS_PLANAR_G = 1 shl 6;
  AVS_PLANAR_B = 1 shl 7;
  AVS_PLANAR_A_ALIGNED = AVS_PLANAR_A or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_R_ALIGNED = AVS_PLANAR_R or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_G_ALIGNED = AVS_PLANAR_G or AVS_PLANAR_ALIGNED;
  AVS_PLANAR_B_ALIGNED = AVS_PLANAR_B or AVS_PLANAR_ALIGNED;

  // Colorspace properties
  AVS_CS_YUVA = 1 shl 27;
  AVS_CS_BGR = 1 shl 28;
  AVS_CS_YUV = 1 shl 29;
  AVS_CS_INTERLEAVED = 1 shl 30;
  AVS_CS_PLANAR = 1 shl 31;

  AVS_CS_SHIFT_SUB_WIDTH = 0;
  AVS_CS_SHIFT_SUB_HEIGHT = 8;
  AVS_CS_SHIFT_SAMPLE_BITS = 16;

  AVS_CS_SUB_WIDTH_MASK = 7 shl AVS_CS_SHIFT_SUB_WIDTH;
  AVS_CS_SUB_WIDTH_1 = 3 shl AVS_CS_SHIFT_SUB_WIDTH; // YV24
  AVS_CS_SUB_WIDTH_2 = 0 shl AVS_CS_SHIFT_SUB_WIDTH; // YV12, I420, YV16
  AVS_CS_SUB_WIDTH_4 = 1 shl AVS_CS_SHIFT_SUB_WIDTH; // YUV9, YV411

  AVS_CS_VPLANEFIRST = 1 shl 3; // YV12, YV16, YV24, YV411, YUV9
  AVS_CS_UPLANEFIRST = 1 shl 4; // I420

  AVS_CS_SUB_HEIGHT_MASK = 7 shl AVS_CS_SHIFT_SUB_HEIGHT;
  AVS_CS_SUB_HEIGHT_1 = 3 shl AVS_CS_SHIFT_SUB_HEIGHT; // YV16, YV24, YV411
  AVS_CS_SUB_HEIGHT_2 = 0 shl AVS_CS_SHIFT_SUB_HEIGHT; // YV12, I420
  AVS_CS_SUB_HEIGHT_4 = 1 shl AVS_CS_SHIFT_SUB_HEIGHT; // YUV9

  AVS_CS_SAMPLE_BITS_MASK = 7 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_8 = 0 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_10 = 5 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_12 = 6 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_14 = 7 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_16 = 1 shl AVS_CS_SHIFT_SAMPLE_BITS;
  AVS_CS_SAMPLE_BITS_32 = 2 shl AVS_CS_SHIFT_SAMPLE_BITS;

  AVS_CS_PLANAR_MASK = AVS_CS_PLANAR or AVS_CS_INTERLEAVED or AVS_CS_YUV or
                       AVS_CS_BGR or AVS_CS_YUVA or AVS_CS_SAMPLE_BITS_MASK or
                       AVS_CS_SUB_HEIGHT_MASK or AVS_CS_SUB_WIDTH_MASK;
  AVS_CS_PLANAR_FILTER = not (AVS_CS_VPLANEFIRST or AVS_CS_UPLANEFIRST);

  AVS_CS_RGB_TYPE  = 1 shl 0;
  AVS_CS_RGBA_TYPE = 1 shl 1;

  AVS_CS_GENERIC_YUV420  = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_2 or AVS_CS_SUB_WIDTH_2;  // 4:2:0 planar
  AVS_CS_GENERIC_YUV422  = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_1 or AVS_CS_SUB_WIDTH_2;  // 4:2:2 planar
  AVS_CS_GENERIC_YUV444  = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_1 or AVS_CS_SUB_WIDTH_1;  // 4:4:4 planar
  AVS_CS_GENERIC_Y       = AVS_CS_PLANAR or AVS_CS_INTERLEAVED or AVS_CS_YUV;                                               // Y only (4:0:0)
  AVS_CS_GENERIC_RGBP    = AVS_CS_PLANAR or AVS_CS_BGR or AVS_CS_RGB_TYPE;                                                  // planar RGB
  AVS_CS_GENERIC_RGBAP   = AVS_CS_PLANAR or AVS_CS_BGR or AVS_CS_RGBA_TYPE;                                                 // planar RGBA
  AVS_CS_GENERIC_YUVA420 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_2 or AVS_CS_SUB_WIDTH_2; // 4:2:0:A planar
  AVS_CS_GENERIC_YUVA422 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_1 or AVS_CS_SUB_WIDTH_2; // 4:2:2:A planar
  AVS_CS_GENERIC_YUVA444 = AVS_CS_PLANAR or AVS_CS_YUVA or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_1 or AVS_CS_SUB_WIDTH_1; // 4:4:4:A planar
  //--------------------------------

  // Specific colorformats
  AVS_CS_UNKNOWN = 0;
  AVS_CS_BGR24 = AVS_CS_RGB_TYPE  or AVS_CS_BGR or AVS_CS_INTERLEAVED;
  AVS_CS_BGR32 = AVS_CS_RGBA_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED;
  AVS_CS_YUY2 = 1 shl 2 or AVS_CS_YUV or AVS_CS_INTERLEAVED;
  //  AVS_CS_YV12  = 1shl3  Reserved
  //  AVS_CS_I420  = 1shl4  Reserved
  AVS_CS_RAW32 = 1 shl 5 or AVS_CS_INTERLEAVED;

  AVS_CS_YV24  = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_8; // YVU 4:4:4 planar
  AVS_CS_YV16  = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_8; // YVU 4:2:2 planar
  AVS_CS_YV12  = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_8; // YVU 4:2:0 planar
  AVS_CS_I420  = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_SAMPLE_BITS_8 or AVS_CS_UPLANEFIRST or AVS_CS_SUB_HEIGHT_2 or AVS_CS_SUB_WIDTH_2; // YUV 4:2:0 planar
  AVS_CS_IYUV  = AVS_CS_I420;
  AVS_CS_YV411 = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_SAMPLE_BITS_8 or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_1 or AVS_CS_SUB_WIDTH_4; // YVU 4:1:1 planar
  AVS_CS_YUV9  = AVS_CS_PLANAR or AVS_CS_YUV or AVS_CS_SAMPLE_BITS_8 or AVS_CS_VPLANEFIRST or AVS_CS_SUB_HEIGHT_4 or AVS_CS_SUB_WIDTH_4; // YVU 4:1:0 planar
  AVS_CS_Y8    = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_8; // Y 4:0:0 planar

  // 10-12-14-16 bit + planar RGB + BRG48/64
  AVS_CS_YUV444P10 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_10; // YUV 4:4:4 10bit samples
  AVS_CS_YUV422P10 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_10; // YUV 4:2:2 10bit samples
  AVS_CS_YUV420P10 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_10; // YUV 4:2:0 10bit samples
  AVS_CS_Y10       = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_10; // Y 4:0:0 10bit samples

  AVS_CS_YUV444P12 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_12; // YUV 4:4:4 12bit samples
  AVS_CS_YUV422P12 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_12; // YUV 4:2:2 12bit samples
  AVS_CS_YUV420P12 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_12; // YUV 4:2:0 12bit samples
  AVS_CS_Y12       = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_12; // Y 4:0:0 12bit samples

  AVS_CS_YUV444P14 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_14; // YUV 4:4:4 14bit samples
  AVS_CS_YUV422P14 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_14; // YUV 4:2:2 14bit samples
  AVS_CS_YUV420P14 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_14; // YUV 4:2:0 14bit samples
  AVS_CS_Y14       = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_14; // Y 4:0:0 14bit samples

  AVS_CS_YUV444P16 = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_16; // YUV 4:4:4 16bit samples
  AVS_CS_YUV422P16 = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_16; // YUV 4:2:2 16bit samples
  AVS_CS_YUV420P16 = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_16; // YUV 4:2:0 16bit samples
  AVS_CS_Y16       = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_16; // Y 4:0:0 16bit samples

  // 32 bit samples (float)
  AVS_CS_YUV444PS = AVS_CS_GENERIC_YUV444 or AVS_CS_SAMPLE_BITS_32; // YUV 4:4:4 32bit samples
  AVS_CS_YUV422PS = AVS_CS_GENERIC_YUV422 or AVS_CS_SAMPLE_BITS_32; // YUV 4:2:2 32bit samples
  AVS_CS_YUV420PS = AVS_CS_GENERIC_YUV420 or AVS_CS_SAMPLE_BITS_32; // YUV 4:2:0 32bit samples
  AVS_CS_Y32      = AVS_CS_GENERIC_Y or AVS_CS_SAMPLE_BITS_32; // Y 4:0:0 32bit samples

  // RGB packed
  AVS_CS_BGR48 = AVS_CS_RGB_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED or AVS_CS_SAMPLE_BITS_16; // BGR 3x16 bit
  AVS_CS_BGR64 = AVS_CS_RGBA_TYPE or AVS_CS_BGR or AVS_CS_INTERLEAVED or AVS_CS_SAMPLE_BITS_16; // BGR 4x16 bit
  // no packed 32 bit (float) support for these legacy types

  // RGB planar
  AVS_CS_RGBP   = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_8;  // Planar RGB 8 bit samples
  AVS_CS_RGBP10 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_10; // Planar RGB 10bit samples
  AVS_CS_RGBP12 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_12; // Planar RGB 12bit samples
  AVS_CS_RGBP14 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_14; // Planar RGB 14bit samples
  AVS_CS_RGBP16 = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_16; // Planar RGB 16bit samples
  AVS_CS_RGBPS  = AVS_CS_GENERIC_RGBP or AVS_CS_SAMPLE_BITS_32; // Planar RGB 32bit samples

  // RGBA planar
  AVS_CS_RGBAP   = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_8;  // Planar RGBA 8 bit samples
  AVS_CS_RGBAP10 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_10; // Planar RGBA 10bit samples
  AVS_CS_RGBAP12 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_12; // Planar RGBA 12bit samples
  AVS_CS_RGBAP14 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_14; // Planar RGBA 14bit samples
  AVS_CS_RGBAP16 = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_16; // Planar RGBA 16bit samples
  AVS_CS_RGBAPS  = AVS_CS_GENERIC_RGBAP or AVS_CS_SAMPLE_BITS_32; // Planar RGBA 32bit samples

  // Planar YUVA
  AVS_CS_YUVA444    = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_8; // YUVA 4:4:4 8bit samples
  AVS_CS_YUVA422    = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_8; // YUVA 4:2:2 8bit samples
  AVS_CS_YUVA420    = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_8; // YUVA 4:2:0 8bit samples

  AVS_CS_YUVA444P10 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_10; // YUVA 4:4:4 10bit samples
  AVS_CS_YUVA422P10 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_10; // YUVA 4:2:2 10bit samples
  AVS_CS_YUVA420P10 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_10; // YUVA 4:2:0 10bit samples

  AVS_CS_YUVA444P12 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_12; // YUVA 4:4:4 12bit samples
  AVS_CS_YUVA422P12 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_12; // YUVA 4:2:2 12bit samples
  AVS_CS_YUVA420P12 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_12; // YUVA 4:2:0 12bit samples

  AVS_CS_YUVA444P14 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_14; // YUVA 4:4:4 14bit samples
  AVS_CS_YUVA422P14 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_14; // YUVA 4:2:2 14bit samples
  AVS_CS_YUVA420P14 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_14; // YUVA 4:2:0 14bit samples

  AVS_CS_YUVA444P16 = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_16; // YUVA 4:4:4 16bit samples
  AVS_CS_YUVA422P16 = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_16; // YUVA 4:2:2 16bit samples
  AVS_CS_YUVA420P16 = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_16; // YUVA 4:2:0 16bit samples

  AVS_CS_YUVA444PS  = AVS_CS_GENERIC_YUVA444 or AVS_CS_SAMPLE_BITS_32; // YUVA 4:4:4 32bit samples
  AVS_CS_YUVA422PS  = AVS_CS_GENERIC_YUVA422 or AVS_CS_SAMPLE_BITS_32; // YUVA 4:2:2 32bit samples
  AVS_CS_YUVA420PS  = AVS_CS_GENERIC_YUVA420 or AVS_CS_SAMPLE_BITS_32; // YUVA 4:2:0 32bit samples

//end of colorspaces

  AVS_IT_BFF = 1 shl 0;
  AVS_IT_TFF = 1 shl 1;
  AVS_IT_FIELDBASED = 1 shl 2;

  AVS_FILTER_TYPE = 1;
  AVS_FILTER_INPUT_COLORSPACE = 2;
  AVS_FILTER_OUTPUT_TYPE = 9;
  AVS_FILTER_NAME = 4;
  AVS_FILTER_AUTHOR = 5;
  AVS_FILTER_VERSION = 6;
  AVS_FILTER_ARGS = 7;
  AVS_FILTER_ARGS_INFO = 8;
  AVS_FILTER_ARGS_DESCRIPTION = 10;
  AVS_FILTER_DESCRIPTION = 11;

  AVS_FILTER_TYPE_AUDIO = 1;
  AVS_FILTER_TYPE_VIDEO = 2;
  AVS_FILTER_OUTPUT_TYPE_SAME = 3;
  AVS_FILTER_OUTPUT_TYPE_DIFFERENT = 4;

  // New 2.6 explicitly defined cache hints.
  AVS_CACHE_NOTHING=10; // Do not cache video.
  AVS_CACHE_WINDOW=11; // Hard protect upto X frames within a range of X from the current frame N.
  AVS_CACHE_GENERIC=12; // LRU cache upto X frames.
  AVS_CACHE_FORCE_GENERIC=13; // LRU cache upto X frames, override any previous CACHE_WINDOW.

  AVS_CACHE_GET_POLICY=30; // Get the current policy.
  AVS_CACHE_GET_WINDOW=31; // Get the current window h_span.
  AVS_CACHE_GET_RANGE=32; // Get the current generic frame range.

  AVS_CACHE_AUDIO=50; // Explicitly do cache audio, X byte cache.
  AVS_CACHE_AUDIO_NOTHING=51; // Explicitly do not cache audio.
  AVS_CACHE_AUDIO_NONE=52; // Audio cache off (auto mode), X byte intial cache.
  AVS_CACHE_AUDIO_AUTO=53; // Audio cache on (auto mode), X byte intial cache.

  AVS_CACHE_GET_AUDIO_POLICY=70; // Get the current audio policy.
  AVS_CACHE_GET_AUDIO_SIZE=71; // Get the current audio cache size.

  AVS_CACHE_PREFETCH_FRAME=100; // Queue request to prefetch frame N.
  AVS_CACHE_PREFETCH_GO=101; // Action video prefetches.

  AVS_CACHE_PREFETCH_AUDIO_BEGIN=120; // Begin queue request transaction to prefetch audio (take critical section).
  AVS_CACHE_PREFETCH_AUDIO_STARTLO=121; // Set low 32 bits of start.
  AVS_CACHE_PREFETCH_AUDIO_STARTHI=122; // Set high 32 bits of start.
  AVS_CACHE_PREFETCH_AUDIO_COUNT=123; // Set low 32 bits of length.
  AVS_CACHE_PREFETCH_AUDIO_COMMIT=124; // Enqueue request transaction to prefetch audio (release critical section).
  AVS_CACHE_PREFETCH_AUDIO_GO=125; // Action audio prefetches.

  AVS_CACHE_GETCHILD_CACHE_MODE=200; // Cache ask Child for desired video cache mode.
  AVS_CACHE_GETCHILD_CACHE_SIZE=201; // Cache ask Child for desired video cache size.
  AVS_CACHE_GETCHILD_AUDIO_MODE=202; // Cache ask Child for desired audio cache mode.
  AVS_CACHE_GETCHILD_AUDIO_SIZE=203; // Cache ask Child for desired audio cache size.

  AVS_CACHE_GETCHILD_COST=220; // Cache ask Child for estimated processing cost.
  AVS_CACHE_COST_ZERO=221; // Child response of zero cost (ptr arithmetic only).
  AVS_CACHE_COST_UNIT=222; // Child response of unit cost (less than or equal 1 full frame blit).
  AVS_CACHE_COST_LOW=223; // Child response of light cost. (Fast)
  AVS_CACHE_COST_MED=224; // Child response of medium cost. (Real time)
  AVS_CACHE_COST_HI=225; // Child response of heavy cost. (Slow)

  AVS_CACHE_GETCHILD_THREAD_MODE=240; // Cache ask Child for thread safetyness.
  AVS_CACHE_THREAD_UNSAFE=241; // Only 1 thread allowed for all instances. 2.5 filters default!
  AVS_CACHE_THREAD_CLASS=242; // Only 1 thread allowed for each instance. 2.6 filters default!
  AVS_CACHE_THREAD_SAFE=243; // Allow all threads in any instance.
  AVS_CACHE_THREAD_OWN=244; // Safe but limit to 1 thread, internally threaded.

  AVS_CACHE_GETCHILD_ACCESS_COST=260; // Cache ask Child for preferred access pattern.
  AVS_CACHE_ACCESS_RAND=261; // Filter is access order agnostic.
  AVS_CACHE_ACCESS_SEQ0=262; // Filter prefers sequential access (low cost)
  AVS_CACHE_ACCESS_SEQ1=263; // Filter needs sequential access (high cost)


type
  PAVS_VideoFrameBuffer = ^AVS_VideoFrameBuffer;
  PAVS_VideoFrame = ^AVS_VideoFrame;
  PAVS_ScriptEnvironment = type Pointer;
  PAVS_Clip = type Pointer;
  PAVS_Value = ^AVS_Value;
  PAVS_VideoInfo = ^AVS_VideoInfo;
  PAVS_FilterInfo = ^AVS_FilterInfo;
  PAVS_Value_array = ^AVS_Value_array;
  PAVS_Value_array_p = ^AVS_Value_array_p;

  AVS_VideoInfo = record
    width, height: Integer;
    fps_numerator, fps_denominator: Cardinal;
    num_frames: Integer;
    pixel_type: Cardinal;
    audio_samples_per_second: Integer;
    sample_type: Integer;
    num_audio_samples: Int64;
    nchannels: Integer;
    image_type: Integer;
  end;

  AVS_VideoFrameBuffer = record
    data: PByte;
    data_size: Integer;
    sequence_number: Cardinal;
    refcount: Cardinal;
  end;

  AVS_VideoFrame = record
    refcount: Integer;
    vfb: PAVS_VideoFrameBuffer;
    offset, pitch, row_size, height, offsetU, offsetV, pitchUV: Integer;
    row_sizeUV, heightUV, offsetA, pitchA, row_sizeA: Integer;
  end;

  AVS_Value = record
    vtype: WideChar;
    array_size: Smallint;
    case AnsiChar of
      'c': (vclip: Pointer);
      'b': (vboolean: LongBool);
      'i': (vinteger: Integer);
      'f': (vfloating_pt: Single);
      's': (vstring: PAnsiChar);
      'a': (varray: PAVS_Value_array);
  end;

  AVS_Value_p = record
    vtype: WideChar;
    array_size: Smallint;
    case Char of
      'c': (vclip: Pointer);
      'b': (vboolean: LongBool);
      'i': (vinteger: Integer);
      'f': (vfloating_pt: Single);
      's': (vstring: PChar);
      'a': (varray: PAVS_Value_array_p);
  end;
  // can moore eg. 100
  AVS_Value_array = array[0..9] of AVS_Value;
  AVS_Value_array_p = array[0..9] of AVS_Value_p;

{$IFDEF WIN32}
  MSVC_AVS_Value = type Int64;
  MSVC_AVS_Value_p = MSVC_AVS_Value;
{$ELSE}
  MSVC_AVS_Value = type AVS_Value;
  MSVC_AVS_Value_p = AVS_Value_p;
{$ENDIF}

  //CacheHints
  TCache = (
    caNOTHING = 0,
    caRANGE = 1,
    caALL = 2,
    caAUDIO = 3,
    caAUDIO_NONE = 4);

  TGetFrameFunc = function(fi: PAVS_FilterInfo; n: Integer): PAVS_VideoFrame; stdcall;
  TGetParityFunc = function(fi: PAVS_FilterInfo; n: Integer): Integer; stdcall;
  TGetAudioFunc = function(fi: PAVS_FilterInfo; buf: Pointer; start: Int64; count: Int64): Integer; stdcall;
  TSetCacheHintsFunc = function(fi: PAVS_FilterInfo; cachehints: Integer; frame_range: Integer): Integer; stdcall;
  TFreeFilterFunc = procedure(fi: PAVS_FilterInfo); stdcall;

  TApplyFunc = function(env: PAVS_ScriptEnvironment; args: MSVC_AVS_Value; user_data: Pointer): MSVC_AVS_Value; stdcall;
  TShutdownFunc = procedure(user_data: Pointer; env: PAVS_ScriptEnvironment); stdcall;

  AVS_FilterInfo = record
    child: PAVS_Clip;
    vi: AVS_VideoInfo;
    env: PAVS_ScriptEnvironment;
    get_frame: TGetFrameFunc;
    get_parity: TGetParityFunc;
    get_audio_func: TGetAudioFunc;
    set_cache_hints_func: TSetCacheHintsFunc;
    free_filter: TFreeFilterFunc;
    error: PAnsiChar;
    user_data: Pointer;
  end;

  // Avisynth.dll loader - avsloader:= TAVS_DllLoader.Create() - avsloader.LoadAvisynth()
  TAS_DllLoader = class
    protected
      FDLLHandle: THandle;
      FIsInit: boolean;
    public
      function LoadAvisynth(const FileName: String=''): boolean;
      procedure UnloadAvisynth;
      property DLLHandle : THandle read FDLLHandle default 0;
      property IsInit: boolean read FIsInit default False;
  end;

const
  // Normal void AVS_Value
  avs_void: AVS_Value = (vtype: 'v'; array_size: 0; vinteger: 0);

  // Empty array AVS_Value (for functions that take no arguments)
  avs_no_arguments: AVS_Value = (vtype: 'a'; array_size: 0; vinteger: 0);

var
// direct
  avs_create_script_environment: function(version: Integer = AVISYNTH_INTERFACE_VERSION): PAVS_ScriptEnvironment; stdcall;
  avs_delete_script_environment: procedure(env: PAVS_ScriptEnvironment); stdcall;
  avs_set_to_clip: procedure(var v: AVS_Value; clip: PAVS_Clip); stdcall;
  avs_new_video_frame: function(env: PAVS_ScriptEnvironment; vi: PAVS_VideoInfo; align: Integer = AVS_FRAME_ALIGN): PAVS_VideoFrame; stdcall;
  avs_release_video_frame: procedure(pvf: PAVS_VideoFrame); stdcall;
  avs_copy_video_frame: function(pvf: PAVS_VideoFrame): PAVS_VideoFrame; stdcall;
  avs_release_clip: procedure(pac: PAVS_Clip); stdcall;
  avs_copy_clip: function(pac: PAVS_Clip): PAVS_Clip; stdcall;
  avs_clip_get_error: function(pac: PAVS_Clip): PAnsiChar; stdcall;
  avs_get_video_info: function(pac: PAVS_Clip): PAVS_VideoInfo; stdcall;
  avs_get_version: function(pac: PAVS_Clip): Integer; stdcall;
  avs_get_frame: function(pac: PAVS_Clip; n: Integer): PAVS_VideoFrame; stdcall;
  avs_get_parity: function(pac: PAVS_Clip; n: Integer): Integer; stdcall;
  avs_get_audio: function(pac: PAVS_Clip; buf: Pointer; start: Int64; count: Int64): PAVS_Clip; stdcall;
  avs_get_cpu_flags: function(env: PAVS_ScriptEnvironment): Cardinal; stdcall;
  avs_set_memory_max: function(env: PAVS_ScriptEnvironment; mem: Integer): Integer; stdcall;
  avs_set_working_dir: function(env: PAVS_ScriptEnvironment; newdir: PAnsiChar): LongBool; stdcall;
  avs_set_cache_hints: function(pac: PAVS_Clip; cachehints: Integer; frame_range: Integer): Integer; stdcall;
  avs_check_version: function(env: PAVS_ScriptEnvironment; version: Integer): LongBool; stdcall;
  avs_save_string: function(env: PAVS_ScriptEnvironment; s: PAnsiChar; length: Integer): PAnsiChar; stdcall;
  avs_add_function: function(env: PAVS_ScriptEnvironment; name: PAnsiChar; params: PAnsiChar; apply: TApplyFunc; user_data: Pointer): Integer; stdcall;
  avs_function_exists: function(env: PAVS_ScriptEnvironment; name: PAnsiChar): LongBool; stdcall;
  avs_make_writable: function(env: PAVS_ScriptEnvironment; var pvf: PAVS_VideoFrame): Integer; stdcall;
  avs_bit_blt: procedure(env: PAVS_ScriptEnvironment; dstp: PByte; dst_pitch: Integer; srcp: PByte; src_pitch: Integer; row_size: Integer; height: Integer); stdcall;
  avs_at_exit: procedure(env: PAVS_ScriptEnvironment; sfunction: TShutdownFunc; user_data: Pointer); stdcall;
  avs_subframe: function(env: PAVS_ScriptEnvironment; src: PAVS_VideoFrame; rel_offset: Integer; new_pitch: Integer; new_row_size: Integer; new_height: Integer): PAVS_VideoFrame; stdcall;

  avs_get_pitch: function(p: PAVS_VideoFrame; plane: Integer = AVS_PLANAR_Y): Integer; stdcall;
  avs_get_row_size: function(p: PAVS_VideoFrame; plane: Integer = AVS_PLANAR_Y): Integer; stdcall;
  avs_get_read_ptr: function(p: PAVS_VideoFrame; plane: Integer = AVS_PLANAR_Y): PByte; stdcall;
  avs_get_height: function(p: PAVS_VideoFrame; plane: Integer = AVS_PLANAR_Y): Integer; stdcall;


// local with type cast (AVS_Value)
function avs_invoke(env: PAVS_ScriptEnvironment; name: PAnsiChar; args: AVS_Value; arg_names: array of PAnsiChar): AVS_Value; overload;
function avs_invoke(env: PAVS_ScriptEnvironment; name: PAnsiChar; args: AVS_Value): AVS_Value; overload;
function avs_invoke_p(env: PAVS_ScriptEnvironment; name: PChar; args: AVS_Value_p): AVS_Value;

function avs_take_clip(v: AVS_Value; env: PAVS_ScriptEnvironment): PAVS_Clip;
procedure avs_release_value(v: AVS_Value);
procedure avs_copy_value(var dest: AVS_Value; src: AVS_Value);
function avs_get_var(env: PAVS_ScriptEnvironment; name: PAnsiChar): AVS_Value;
function avs_set_var(env: PAVS_ScriptEnvironment; name: PAnsiChar; val: AVS_Value): Boolean;
function avs_set_global_var(env: PAVS_ScriptEnvironment; name: PAnsiChar; const val: AVS_Value): Boolean;
function avs_new_c_filter(e: PAVS_ScriptEnvironment; var fi: PAVS_FilterInfo; child: AVS_Value; store_child: Boolean = True): PAVS_Clip;

// direct/local convertet
function avs_is_yv24(vi: PAVS_VideoInfo): Boolean;
function avs_is_yv16(vi: PAVS_VideoInfo): Boolean;
function avs_is_yv12(vi: PAVS_VideoInfo): Boolean;
function avs_is_yv411(vi: PAVS_VideoInfo): Boolean;
function avs_is_yv8(vi: PAVS_VideoInfo): Boolean;
function avs_get_error(env: PAVS_ScriptEnvironment): PAnsiChar;
//avs+ with fake_func for classic avs
function avs_is_rgb64(vi: PAVS_VideoInfo): Boolean;
function avs_is_rgb48(vi: PAVS_VideoInfo): Boolean;
function avs_is_444(vi: PAVS_VideoInfo): Boolean;
function avs_is_422(vi: PAVS_VideoInfo): Boolean;
function avs_is_420(vi: PAVS_VideoInfo): Boolean;
function avs_is_y(vi: PAVS_VideoInfo): Boolean;
function avs_bits_per_component(vi: PAVS_VideoInfo): Int64;

// locale
function avs_defined(v: AVS_Value): Boolean;
function avs_is_clip(v: AVS_Value): Boolean;
function avs_is_bool(v: AVS_Value): Boolean;
function avs_is_int(v: AVS_Value): Boolean;
function avs_is_float(v: AVS_Value): Boolean;
function avs_is_string(v: AVS_Value): Boolean;
function avs_is_array(v: AVS_Value): Boolean;
function avs_is_error(v: AVS_Value): Boolean;
function avs_as_bool(v: AVS_Value): Boolean;
function avs_as_int(v: AVS_Value): Integer;
function avs_as_string(v: AVS_Value): PAnsiChar;
function avs_as_float(v: AVS_Value): Single;
function avs_as_error(v: AVS_Value): PAnsiChar;
function avs_as_array(v: AVS_Value): PAVS_Value_array;
function avs_as_bool_def(v: AVS_Value; default: Boolean): Boolean;
function avs_as_int_def(v: AVS_Value; default: Integer): Integer;
function avs_as_string_def(v: AVS_Value; default: PAnsiChar): PAnsiChar;
function avs_as_float_def(v: AVS_Value; default: Single): Single;
function avs_array_size(v: AVS_Value): Integer;
function avs_array_elt(v: AVS_Value; index: Integer): AVS_Value;
function avs_new_value_bool(v0: Boolean): AVS_Value;
function avs_new_value_int(v0: Integer): AVS_Value;
function avs_new_value_string(v0: PAnsiChar): AVS_Value;
function avs_new_value_string_p(v0: PChar): AVS_Value_p;
function avs_new_value_float(v0: Single): AVS_Value;
function avs_new_value_error(v0: PAnsiChar): AVS_Value;
function avs_new_value_array(v0: PAVS_Value_array; size: Integer): AVS_Value;
function avs_new_value_array_p(v0: PAVS_Value_array_p; size: Integer): AVS_Value_p;
// Warn, returned value must be released
function avs_new_value_clip(v0: PAVS_Clip): AVS_Value;

// local VideoInfo
function avs_is_rgb(vi: PAVS_VideoInfo): Boolean;
function avs_is_rgb32(vi: PAVS_VideoInfo): Boolean;
function avs_is_rgb24(vi: PAVS_VideoInfo): Boolean;
function avs_is_yuv(vi: PAVS_VideoInfo): Boolean;
function avs_is_yuy2(vi: PAVS_VideoInfo): Boolean;
function avs_has_audio(vi: PAVS_VideoInfo): Boolean;
function avs_has_video(vi: PAVS_VideoInfo): Boolean;
function avs_is_bff(vi: PAVS_VideoInfo): Boolean;
function avs_is_tff(vi: PAVS_VideoInfo): Boolean;
function avs_is_field_based(vi: PAVS_VideoInfo): Boolean;

implementation

// fake for avs classic
function fake_false(vi: PAVS_VideoInfo): boolean;
begin
  Result:= False;
end;

function fake_bits_per_component(vi: PAVS_VideoInfo): Integer;
begin
  Result:= 8;
end;

var
  avsDLL: String = 'avisynth.dll';

  // Imported functions using AVS_Value which need special typecasting to work properly
  ext_avs_invoke: function(env: PAVS_ScriptEnvironment; name: PAnsiChar; args: MSVC_AVS_Value; arg_names: PPAnsiChar): MSVC_AVS_Value; stdcall;
  ext_avs_invoke_p: function(env: PAVS_ScriptEnvironment; name: PChar; args: MSVC_AVS_Value_p; arg_names: PPChar): MSVC_AVS_Value; stdcall;
  ext_avs_take_clip: function(v: MSVC_AVS_Value; env: PAVS_ScriptEnvironment): PAVS_Clip; stdcall;
  ext_avs_release_value: procedure(v: MSVC_AVS_Value); stdcall;
  ext_avs_copy_value: procedure(var dest: AVS_Value; src: MSVC_AVS_Value); stdcall;
  ext_avs_get_var: function(env: PAVS_ScriptEnvironment; name: PAnsiChar): MSVC_AVS_Value; stdcall;
  ext_avs_set_var: function (env: PAVS_ScriptEnvironment; name: PAnsiChar; val: MSVC_AVS_Value): LongBool; stdcall;
  ext_avs_set_global_var: function (env: PAVS_ScriptEnvironment; name: PAnsiChar; val: MSVC_AVS_Value): LongBool; stdcall;
  ext_avs_new_c_filter: function(e: PAVS_ScriptEnvironment; var fi: PAVS_FilterInfo; child: MSVC_AVS_Value; store_child: LongBool): PAVS_Clip; stdcall;

  // Result convertet to boolean
  ext_avs_is_yv24: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_yv16: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_yv12: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_yv411: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_yv8: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_get_error: function(env: PAVS_ScriptEnvironment): PAnsiChar; stdcall;

  // avs+ with fake_func for classic
  ext_avs_is_rgb64: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_rgb48: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_444: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_422: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_420: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_is_y: function(vi: PAVS_VideoInfo): Integer; stdcall;
  ext_avs_bits_per_component: function(vi: PAVS_VideoInfo): Int64; stdcall;  // strange, returned value Int64


function TAS_DllLoader.LoadAvisynth(const FileName: String=''): boolean;
var
  avsplus: boolean;
begin
  If FDLLHandle <> 0 then
  begin
    Result:= true;
    exit;
  end;
  Result:= false;
  FIsInit:= false;
  avsplus:= True;
  If FileName <> '' then avsDLL:= FileName;
  FDLLHandle:= LoadLibraryW(PWideChar(avsDLL));
  If FDLLHandle = 0 then
    exit;

  @avs_create_script_environment:= GetProcAddress(FDLLHandle, 'avs_create_script_environment');
  @avs_delete_script_environment:= GetProcAddress(FDLLHandle, 'avs_delete_script_environment');
  @avs_set_to_clip:= GetProcAddress(FDLLHandle, 'avs_set_to_clip');
  @avs_new_video_frame:= GetProcAddress(FDLLHandle, 'avs_new_video_frame');
  @avs_release_video_frame:= GetProcAddress(FDLLHandle, 'avs_release_video_frame');
  @avs_copy_video_frame:= GetProcAddress(FDLLHandle, 'avs_copy_video_frame');
  @avs_release_clip:= GetProcAddress(FDLLHandle, 'avs_release_clip');
  @avs_copy_clip:= GetProcAddress(FDLLHandle, 'avs_copy_clip');
  @avs_clip_get_error:= GetProcAddress(FDLLHandle, 'avs_clip_get_error');
  @avs_get_video_info:= GetProcAddress(FDLLHandle, 'avs_get_video_info');
  @avs_get_version:= GetProcAddress(FDLLHandle, 'avs_get_version');
  @avs_get_frame:= GetProcAddress(FDLLHandle, 'avs_get_frame');
  @avs_get_parity:= GetProcAddress(FDLLHandle, 'avs_get_parity');
  @avs_get_audio:= GetProcAddress(FDLLHandle, 'avs_get_audio');
  @avs_set_cache_hints:= GetProcAddress(FDLLHandle, 'avs_set_cache_hints');
  @avs_get_cpu_flags:= GetProcAddress(FDLLHandle, 'avs_get_cpu_flags');
  @avs_check_version:= GetProcAddress(FDLLHandle, 'avs_check_version');
  @avs_save_string:= GetProcAddress(FDLLHandle, 'avs_save_string');
  @avs_add_function:= GetProcAddress(FDLLHandle, 'avs_add_function');
  @avs_function_exists:= GetProcAddress(FDLLHandle, 'avs_function_exists');
  @avs_make_writable:= GetProcAddress(FDLLHandle, 'avs_make_writable');
  @avs_bit_blt:= GetProcAddress(FDLLHandle, 'avs_bit_blt');
  @avs_at_exit:= GetProcAddress(FDLLHandle, 'avs_at_exit');
  @avs_subframe:= GetProcAddress(FDLLHandle, 'avs_subframe');
  @avs_set_memory_max:= GetProcAddress(FDLLHandle, 'avs_set_memory_max');
  @avs_set_working_dir:= GetProcAddress(FDLLHandle, 'avs_set_working_dir');

  @avs_get_pitch:= GetProcAddress(FDLLHandle, 'avs_get_pitch_p');
  @avs_get_row_size:= GetProcAddress(FDLLHandle, 'avs_get_row_size_p');
  @avs_get_read_ptr:= GetProcAddress(FDLLHandle, 'avs_get_read_ptr_p');
  @avs_get_height:= GetProcAddress(FDLLHandle,'avs_get_height_p');

  // Imported functions using AVS_Value which need special typecasting to work properly
  @ext_avs_invoke:= GetProcAddress(FDLLHandle, 'avs_invoke');
  @ext_avs_invoke_p:= GetProcAddress(FDLLHandle, 'avs_invoke');
  @ext_avs_take_clip:= GetProcAddress(FDLLHandle, 'avs_take_clip');
  @ext_avs_release_value:= GetProcAddress(FDLLHandle, 'avs_release_value');
  @ext_avs_copy_value:= GetProcAddress(FDLLHandle,'avs_copy_value');
  @ext_avs_get_var:= GetProcAddress(FDLLHandle, 'avs_get_var');
  @ext_avs_set_var:= GetProcAddress(FDLLHandle, 'avs_set_var');
  @ext_avs_set_global_var:= GetProcAddress(FDLLHandle, 'avs_set_global_var');
  @ext_avs_new_c_filter:= GetProcAddress(FDLLHandle, 'avs_new_c_filter');

  // Result local convertet
  @ext_avs_is_yv24:= GetProcAddress(FDLLHandle, 'avs_is_yv24');
  @ext_avs_is_yv16:= GetProcAddress(FDLLHandle, 'avs_is_yv16');
  @ext_avs_is_yv12:= GetProcAddress(FDLLHandle, 'avs_is_yv12');
  @ext_avs_is_yv411:= GetProcAddress(FDLLHandle, 'avs_is_yv411');
  @ext_avs_is_yv8:= GetProcAddress(FDLLHandle, 'avs_is_yv8');
  @ext_avs_get_error:= GetProcAddress(FDLLHandle, 'avs_get_error');

  // avs+
  Try
    @ext_avs_is_rgb64:= GetProcAddress(FDLLHandle, 'avs_is_rgb64');
    @ext_avs_is_rgb48:= GetProcAddress(FDLLHandle, 'avs_is_rgb48');
    @ext_avs_is_444:= GetProcAddress(FDLLHandle, 'avs_is_444');
    @ext_avs_is_422:= GetProcAddress(FDLLHandle, 'avs_is_422');
    @ext_avs_is_420:= GetProcAddress(FDLLHandle, 'avs_is_420');
    @ext_avs_is_y:= GetProcAddress(FDLLHandle, 'avs_is_y');
    @ext_avs_bits_per_component:= GetProcAddress(FDLLHandle, 'avs_bits_per_component');
  except
    avsplus:= false;
  End;

  If Assigned(avs_create_script_environment) then
  begin
    Result:= True;
    FIsInit:= True;
    // classic avs  @fake_func
    If not Assigned(ext_avs_is_rgb64) or not avsplus then
    begin
      ext_avs_is_rgb64:= @fake_false;
      ext_avs_is_rgb48:= @fake_false;
      ext_avs_is_444:= ext_avs_is_yv24;
      ext_avs_is_422:= ext_avs_is_yv16;
      ext_avs_is_420:= ext_avs_is_yv12;
      ext_avs_is_y:= ext_avs_is_yv8;
      ext_avs_bits_per_component:= @fake_bits_per_component;
    end;
  end;
end;

procedure TAS_DllLoader.UnloadAvisynth;
begin
  If FDLLHandle <> 0 then
    FreeLibrary(FDLLHandle);
  FDLLHandle:= 0;
  FIsInit:= false;
end;


///////////////////////////////////////////////////////////////////////////////////
// Typecasting (only for 32bit) for c++ records less than or equal to 8 bytes in size (AVS_Values)
///////////////////////////////////////////////////////////////////////////////////

function avs_invoke(env: PAVS_ScriptEnvironment; name: PAnsiChar; args: AVS_Value; arg_names: array of PAnsiChar): AVS_Value;
begin
  Result:= AVS_Value(ext_avs_invoke(env, name, MSVC_AVS_Value(args), @arg_names));
end;

function avs_invoke(env: PAVS_ScriptEnvironment; name: PAnsiChar; args: AVS_Value): AVS_Value;
begin
  Result:= AVS_Value(ext_avs_invoke(env, name, MSVC_AVS_Value(args), nil));
end;

function avs_invoke_p(env: PAVS_ScriptEnvironment; name: PChar; args: AVS_Value_p): AVS_Value;
begin
  Result:= AVS_Value(ext_avs_invoke_p(env, name, MSVC_AVS_Value_p(args), nil));
end;

procedure avs_release_value(v: AVS_Value);
begin
  ext_avs_release_value(MSVC_AVS_Value(v));
end;

function avs_take_clip(v: AVS_Value; env: PAVS_ScriptEnvironment): PAVS_Clip;
begin
  Result:= ext_avs_take_clip(MSVC_AVS_Value(v), env);
end;

procedure avs_copy_value(var dest: AVS_Value; src: AVS_Value);
begin
  ext_avs_copy_value(dest, MSVC_AVS_Value(src));
end;

function avs_get_var(env: PAVS_ScriptEnvironment; name: PAnsiChar): AVS_Value;
begin
  Result:= AVS_Value(ext_avs_get_var(env, name));
end;

function avs_set_var(env: PAVS_ScriptEnvironment; name: PAnsiChar; val: AVS_Value): Boolean;
begin
  Result:= Boolean(ext_avs_set_var(env, name, MSVC_AVS_Value(val)));
end;

function avs_set_global_var(env: PAVS_ScriptEnvironment; name: PAnsiChar; const val: AVS_Value): Boolean;
begin
  Result:= Boolean(ext_avs_set_global_var(env, name, MSVC_AVS_Value(val)));
end;

function avs_new_c_filter(e: PAVS_ScriptEnvironment; var fi: PAVS_FilterInfo; child: AVS_Value; store_child: Boolean = True): PAVS_Clip;
begin
  Result:= ext_avs_new_c_filter(e, fi, MSVC_AVS_Value(child), store_child);
end;


// locale
function avs_defined(v: AVS_Value): Boolean;
begin
  Result:= v.vtype <> 'v';
end;

function avs_is_clip(v: AVS_Value): Boolean;
begin
  Result:= v.vtype = 'c';
end;

function avs_is_bool(v: AVS_Value): Boolean;
begin
  Result:= v.vtype = 'b';
end;

function avs_is_int(v: AVS_Value): Boolean;
begin
  Result:= v.vtype = 'i';
end;

function avs_is_float(v: AVS_Value): Boolean;
begin
  Result:= (v.vtype = 'f') // or (v.vtype = 'i') ?? komisch;
end;

function avs_is_string(v: AVS_Value): Boolean;
begin
  Result:= v.vtype = 's';
end;

function avs_is_array(v: AVS_Value): Boolean;
begin
  Result:= v.vtype = 'a';
end;

function avs_is_error(v: AVS_Value): Boolean;
begin
  Result:= v.vtype = 'e';
end;

function avs_as_bool(v: AVS_Value): Boolean;
begin
  Result:= v.vboolean;
end;

function avs_as_int(v: AVS_Value): Integer;
begin
  Result:= v.vinteger;
end;

function avs_as_string(v: AVS_Value): PAnsiChar;
begin
  if avs_is_error(v) or avs_is_string(v) then
    Result := v.vstring
  else
    Result:= nil;
end;

function avs_as_float(v: AVS_Value): Single;
begin
  if avs_is_int(v) then
    Result:= v.vinteger
  else
    Result:= v.vfloating_pt;
end;

function avs_as_error(v: AVS_Value): PAnsiChar;
begin
  if avs_is_error(v) then
    Result := v.vstring
  else
    Result:= nil;
end;

function avs_as_array(v: AVS_Value): PAVS_Value_array;
begin
  Result:= v.varray;
end;

function avs_as_bool_def(v: AVS_Value; default: Boolean): Boolean;
begin
  if avs_is_bool(v) then
    Result:= avs_as_bool(v)
  else
    Result:= default;
end;

function avs_as_int_def(v: AVS_Value; default: Integer): Integer;
begin
  if avs_is_int(v) then
    Result:= avs_as_int(v)
  else
    Result:= default;
end;

function avs_as_string_def(v: AVS_Value; default: PAnsiChar): PAnsiChar;
begin
  if avs_is_string(v) then
    Result:= avs_as_string(v)
  else
    Result:= default;
end;

function avs_as_float_def(v: AVS_Value; default: Single): Single;
begin
  if avs_is_float(v) then
    Result:= avs_as_float(v)
  else
    Result:= default;
end;

function avs_array_size(v: AVS_Value): Integer;
begin
  if avs_is_array(v) then
    Result:= v.array_size
  else
    Result:= 1;
end;

function avs_array_elt(v: AVS_Value; index: Integer): AVS_Value;
begin
  if avs_is_array(v) and (index >= 0) and (index < v.array_size) then
    Result:= v.varray^[index]
  else
    Result:= v;
end;

function avs_new_value_bool(v0: Boolean): AVS_Value;
begin
  Result.vtype := 'b';
  Result.vboolean := v0;
end;

function avs_new_value_int(v0: Integer): AVS_Value;
begin
  Result.vtype := 'i';
  Result.vinteger := v0;
end;

function avs_new_value_string(v0: PAnsiChar): AVS_Value;
begin
  Result.vtype := 's';
  Result.vstring := v0;
end;

function avs_new_value_string_p(v0: PChar): AVS_Value_p;
begin
  Result.vtype := 's';
  Result.vstring := v0;
end;

function avs_new_value_float(v0: Single): AVS_Value;
begin
  Result.vtype := 'f';
  Result.vfloating_pt := v0;
end;

function avs_new_value_error(v0: PAnsiChar): AVS_Value;
begin
  Result.vtype := 'e';
  Result.vstring := v0;
end;

// Warn, returned value must be released
function avs_new_value_clip(v0: PAVS_Clip): AVS_Value;
begin
  //Result.vtype := 'c';
  //Result.vclip := v0;
  avs_set_to_clip(Result, v0);
end;

function avs_new_value_array(v0: PAVS_Value_array; size: Integer): AVS_Value;
begin
  Result.vtype := 'a';
  Result.varray := v0;
  Result.array_size := size;
end;

function avs_new_value_array_p(v0: PAVS_Value_array_p; size: Integer): AVS_Value_p;
begin
  Result.vtype := 'a';
  Result.varray := v0;
  Result.array_size := size;
end;


// direct result convertet
function avs_get_error(env: PAVS_ScriptEnvironment): PAnsiChar;
// avs returns NULL or 0 or PChar
var
  p: PAnsiChar;
begin
  Result:= '';
  Try
    p:= ext_avs_get_error(env);
    if Assigned(p) and (p <> '') then
      Result:= p;
  except
  End;
end;

function avs_is_yv24(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_yv24(vi))
end;

function avs_is_yv16(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_yv16(vi))
end;

function avs_is_yv12(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_yv12(vi))
end;

function avs_is_yv411(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_yv411(vi))
end;

function avs_is_yv8(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_yv8(vi))
end;

// avs+ and fake_func for classic
function avs_is_rgb64(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_rgb64(vi))
end;

function avs_is_rgb48(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_rgb48(vi))
end;

function avs_is_444(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_444(vi))
end;

function avs_is_422(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_422(vi))
end;

function avs_is_420(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_420(vi))
end;

function avs_is_y(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= Boolean(ext_avs_is_y(vi))
end;

function avs_bits_per_component(vi: PAVS_VideoInfo): Int64;
begin
  Result:= ext_avs_bits_per_component(vi)
end;


// local VideoInfo
function avs_is_rgb(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.pixel_type and AVS_CS_BGR <> 0
end;

function avs_is_rgb32(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= (vi.pixel_type and AVS_CS_BGR32 = AVS_CS_BGR32) and
           (vi.pixel_type and AVS_CS_SAMPLE_BITS_MASK = AVS_CS_SAMPLE_BITS_8);
end;

function avs_is_rgb24(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= (vi.pixel_type and AVS_CS_BGR24 = AVS_CS_BGR24) and
           (vi.pixel_type and AVS_CS_SAMPLE_BITS_MASK = AVS_CS_SAMPLE_BITS_8)
end;

function avs_is_yuv(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.pixel_type and AVS_CS_YUV <> 0;
end;

function avs_is_yuy2(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.pixel_type and AVS_CS_YUY2 = AVS_CS_YUY2
end;

function avs_has_audio(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.audio_samples_per_second <> 0
end;

function avs_has_video(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.width > 0
end;

function avs_is_bff(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.image_type and AVS_IT_BFF <> 0
end;

function avs_is_tff(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.image_type and AVS_IT_TFF <> 0
end;

function avs_is_field_based(vi: PAVS_VideoInfo): Boolean;
begin
  Result:= vi.image_type and AVS_IT_FIELDBASED <> 0
end;

end.
