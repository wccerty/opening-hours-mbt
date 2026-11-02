# 查重记录 / Deduplication Record

- 日期：2026-11-02（Asia/Shanghai）
- MoonBit CLI：`moon 0.1.20261023 (3778465 2026-10-23)`，工具链已安装，因此没有重复执行安装脚本。
- 范围：MoonBit 包索引与 GitHub 公开仓库/代码检索；仅判断是否已有专门实现 OSM `opening_hours` 的 MoonBit 包。

## MoonBit 包索引

### 1. `moon search "opening hours"`

摘要：两个命中；均为通用验证/数据结构库，非 OSM 营业时间解析。 退出码：0。

````text
2 modules found

moonbit-community/verified@0.0.3 (1504 downloads)
  —
  Repository: https://github.com/moonbit-community/verified

Juwan-Hwang/moon-certified@0.1.1 (62 downloads)
  Core algorithms and data structures for MoonBit — partially formally verified
  Repository: https://github.com/Juwan-Hwang/moon-certified

Run `moon add <module>@<version>` to add a dependency.
````

### 2. `moon search "opening_hours"`

摘要：两个命中；均为通用验证/数据结构库，非 OSM 营业时间解析。 退出码：0。

````text
2 modules found

moonbit-community/verified@0.0.3 (1504 downloads)
  —
  Repository: https://github.com/moonbit-community/verified

Juwan-Hwang/moon-certified@0.1.1 (62 downloads)
  Core algorithms and data structures for MoonBit — partially formally verified
  Repository: https://github.com/Juwan-Hwang/moon-certified

Run `moon add <module>@<version>` to add a dependency.
````

### 3. `moon search "opening hours parser"`

摘要：无结果。 退出码：0。

````text
No modules found.
````

### 4. `moon search "business hours"`

摘要：无结果。 退出码：0。

````text
No modules found.
````

### 5. `moon search "osm"`

摘要：两个命中；均为通用验证/数据结构库，非 OSM 营业时间解析。 退出码：0。

````text
2 modules found

wskwsk68/membrane@0.2.2 (41 downloads)
  MoonBit membrane separation calculation library (gas separation, reverse osmosis, nanofiltration)
  Repository: https://github.com/wskwsk68/moonbit-membrane

  wskwsk68/membrane/examples/benchmark
    The package has no public API documentation or README description.

    Keywords: benchmark, examples, membrane, wskwsk68, empty, undocumented, no public API

  wskwsk68/membrane/examples/desalination
    The supplied sources contain no README content and no public API documentation for this package; only its module and package name are available.

    Keywords: desalination, membrane, examples, wskwsk68/membrane, membrane/examples/desalination

  wskwsk68/membrane/examples/gas_separation
    This package currently has no public API documentation or README available, so its purpose and use cases cannot be determined from the provided sources.

    Keywords: gas separation, membrane, example, wskwsk68

  wskwsk68/membrane/membrane
    The membrane package provides a Membrane struct with name, thickness, and area, and a Permeance struct with component name and value, plus a function to compute ideal selectivity as the ratio of two permeances.

    Keywords: membrane, permeance, selectivity, ideal selectivity, membrane material, gas separation, barrier, MoonBit, struct, Eq, Debug, constructor, component, thickness, area

  wskwsk68/membrane/process
    This package provides data types and functions for modeling, simulating, and evaluating membrane separation processes, including stage material balance, multicomponent permeation, calibration, cost estimation, health and reliability simulation, and screening correlations.

    Keywords: membrane process, calibration, cost estimation, design evaluation, health simulation, screening, material selection, permeation, cascade, parallel, rejection, recovery, stage result, dynamic simulation, plant feasibility

Suquster/moonbit-pathfinding@0.2.0 (78 downloads)
  A MoonBit pathfinding and graph algorithms library with executable documentation, runtime-checked proof predicates, and multi-backend verification gates. Built for OSC 2026.
  Repository: https://github.com/Suquster/moonbit-pathfinding

  Suquster/moonbit-pathfinding/src/graph
    Graph data structures and pathfinding utilities for MoonBit, covering immutable adjacency-list graphs (Graph, GraphBuilder), compressed sparse row graphs (CsrGraph), and a unified GraphRepr over adjacency matrix, edge list, and CSR formats. It also provides OSM edge-list loading with synthetic grid fallback, lazy path iteration, structured PathError diagnost

    Keywords: graph, pathfinding, CsrGraph, GraphBuilder, GraphRepr, LazyPath, PathError, OSM, synthetic grid, shortest path, BFS, successors, neighbors, 邻接表, 最短路

  Suquster/moonbit-pathfinding/src/playground
    The playground package provides a Grid pathfinding session for an interactive visualizer, with grid editing, algorithm selection (BFS, DFS, Dijkstra, AStar, JPS), and step-by-step search traces via trace_search. It also exposes an OSM graph session for routing with one-way or bidirectional Dijkstra and a pg_* API that returns error codes for host integration

    Keywords: pathfinding, playground, Grid, AStar, JPS, Dijkstra, BFS, DFS, trace_search, StepTrace, StepState, 曼哈顿距离, 网格寻路, OSM, pg_compute

Run `moon add <module>@<version>` to add a dependency.
````

### 6. `moon search "opening"`

摘要：20 个命中；显示的包与本项目无关（如文件打开、SQLite 等）。 退出码：0。

````text
20 modules found

NoahLiu/ffmpeg-mbt@0.2.0 (45 downloads)
  FFmpeg 的 MoonBit 封装：音视频解码/转码/封装的进程内绑定，链接系统 ffmpeg 开发包，为 gui-media 提供媒体解码层
  Repository: https://github.com/lb091188/moonbit-native-gui

  NoahLiu/ffmpeg-mbt/src
    Provides a Demuxer for opening media files and decoding video frames to RGBA or audio to s16 interleaved PCM, with stream inspection and seeking. Also reads embedded subtitle streams into SubCue lists and exposes ffmpeg availability and version helpers.

    Keywords: ffmpeg, demuxer, media, decode, rgba, pcm, subtitle, SubCue, seek, ffmpeg_version, ffmpeg_supported, subtitle_cues, subtitle_ass_text, VfError, 音视频

moonbit-community/proton_shell@0.6.0 (24294 downloads)
  Native shell helpers for MoonBit.
  Repository: https://github.com/moonbit-community/proton/tree/main/sys/shell

  moonbit-community/proton_shell
    proton_shell provides cross-platform native shell integration for MoonBit, including opening URLs or filesystem paths with the default application, revealing and selecting items in the native file manager, moving items to the system trash, and playing the default alert sound. It also exposes platform support checks and a ShellError for failed shell requests.

    Keywords: proton_shell, shell, cross-platform, open URL, open file, reveal item, trash item, recycle bin, beep, ShellError, ensure_supported, is_supported, native platform, filesystem

moonbit-community/sqlite3@0.2.3 (6097 downloads)
  A lightweight, low-level SQLite3 binding for MoonBit, providing a thin interface over the SQLite3 C API.
  Repository: https://github.com/moonbit-community/sqlite3.mbt

  moonbit-community/sqlite3
    moonbit-community/sqlite3 is a low-level SQLite3 binding for MoonBit that exposes the core C API workflow: opening connections, preparing statements, binding parameters, stepping through rows, and reading column values, including BLOB and dynamically typed Value values. It supports a native backend with vendored SQLite and a Wasm backend via moonrun host imp

    Keywords: sqlite3, SQLite, MoonBit, database, embedded database, prepared statement, Connection, Statement, bind, column, BLOB, Value, async, ErrorCode, 数据库

Nanaloveyuki/wasee-moon@0.1.0 (36 downloads)
  Android WASI host integration for MoonBit guests.
  Repository: https://github.com/Nanaloveyuki/wasee-moon

  Nanaloveyuki/wasee-moon/bridge
    Provides a MoonBit bridge for Android USB transport operations, including opening, controlling, and communicating with USB devices through bulk read/write and control transfers, with an AndroidUsbTransport struct that implements the UsbTransport trait.

    Keywords: Android, USB, transport, bridge, MoonBit, AndroidUsbTransport, UsbTransport, bulk_read, bulk_write, control transfer, device info, open_device, list_devices, AOA

moonbitlang/ooxml@0.1.1 (6817 downloads)
  Shared OPC packaging and XML support for office.mbt
  Repository: https://github.com/moonbitlang/office.mbt

  moonbitlang/ooxml/opc
    This package provides structs for handling OPC packages, including error types like OpcError, the ContentTypes catalog, and the Package structure itself. Key functions include opening a package from ZIP bytes, managing parts, and resolving content types based on OPC rules.

    Keywords: OPC package, ContentTypes, Package, Part, OpcError, Relationships, rt_image, rel_type

moonbitstack/moonsqlite@0.3.3 (367 downloads)
  SQLite driver for moondb/moonorm — native FFI, amalgamation vendored here (isolated).
  Repository: https://github.com/moonbitstack/moondb

  moonbitstack/moonsqlite
    moonsqlite provides a native SQLite driver implementation for moondb, allowing any moondb query layer like moonorm to interface with a real SQLite database. Key public use cases include opening a connection using SqliteDriver::open and running SQL commands via execute, query, or query_stream.

    Keywords: moonsqlite, moondb, SqliteDriver, SQLite driver, moonorm, SqliteCursor, Driver, execute, query, native-gated

KKKIIO/sqlite@0.3.2 (88 downloads)
  SQLite bindings for MoonBit that link against your own libsqlite3 (native) or node:sqlite (js)
  Repository: https://github.com/kkkiio/sqlite.mbt

  KKKIIO/sqlite
    KKKIIO/sqlite provides SQLite database bindings for MoonBit on native (C FFI) and JavaScript (Node.js) targets. It offers Database and Statement types for opening databases, executing SQL, preparing and binding statements, iterating query results, and managing transactions with BEGIN, COMMIT, ROLLBACK, and SAVEPOINT.

    Keywords: sqlite, sqlite3, MoonBit, database, Database, Statement, SqlValue, prepared statement, bind_all, iter, transaction, savepoint, native, JavaScript, Node.js

zlhahaha/zarr@0.7.0 (64 downloads)
  Zarr v2 and v3 chunked array storage for MoonBit
  Repository: https://github.com/zlhahaha/zarr

  zlhahaha/zarr/hierarchy
    Provides hierarchy operations over Zarr metadata stored in MemoryStore: creating group trees along paths, opening unambiguous nodes as GroupMetadata, storing or reading attributes for arrays/groups (v2/v3), writing validated group documents while preserving arrays, all returning explicit success flags or optional values where applicable.

    Keywords: Zarr hierarchy, group tree creation, Open group metadata, Read/write attributes, V2/V3 formats, Storage layout, Array/Group manipulation, metadata management

  zlhahaha/zarr/store/s3
    Read-only S3-compatible object-store adapter for Zarr. It provides S3Store for opening validated array metadata and hydrating only the metadata and ordinary or sharded chunks covered by a given origin and extent into a MemoryStore, plus Credentials for S3 Signature Version 4 explicit credentials.

    Keywords: zarr, S3Store, Credentials, S3-compatible, object store, read-only, MinIO, endpoint, bucket, open_array, hydrate_region, ArrayMetadata, MemoryStore, shard, S3 Signature Version 4

  zlhahaha/zarr/array
    Typed Zarr array access backed by MemoryStore, covering bool, signed and unsigned 8/16/32/64-bit integers, and float32/float64 arrays. It provides creation, opening from store or metadata, metadata JSON builders, plus read, write, read_region, and write_region operations for chunked N-dimensional data, with fill values used for missing chunks.

    Keywords: zarr, array, chunk, MemoryStore, read_region, write_region, metadata, fill value, C order, BoolArray, U8Array, I32Array, F64Array, 多维数组, 分块

  zlhahaha/zarr/store/fs
    Provides a persistent, native-only local filesystem Zarr key/value store (FileStore) with typed array views for bool, int8/16/32/64, uint8/16/32/64, float32/64. It supports creating, opening, and reading/writing individual elements and C-order regions across filesystem chunks, plus consolidated v2/v3 metadata, shard read statistics, and read limits.

    Keywords: zarr, FileStore, filesystem, native, array, chunk, read_region, write_region, consolidated metadata, Zarr v2, Zarr v3, ShardReadStats, ReadLimits, zlhahaha/zarr/store/fs, 本地文件…

colmugx/sqlite3@0.2.0 (54 downloads)
  A lightweight, low-level SQLite3 binding for MoonBit, providing a thin interface over the SQLite3 C API.
  Repository: https://github.com/colmugx/sqlite3.mbt

  colmugx/sqlite3
    A lightweight, low-level SQLite3 binding for MoonBit that exposes the core SQLite C API workflow, including opening connections, preparing statements, binding parameters, stepping through results, and reading column values. It supports Int, Int64, Double, String, and Bytes types for bind/read operations and is intended for direct embedded database use withou

    Keywords: SQLite3, MoonBit SQLite, SQLite绑定, SQLite binding, SQLite3 C API, 数据库, embedded database, Statement, Connection, Bind trait, Column trait, SqliteError, SQLite result codes, BLOB, native target…

  colmugx/sqlite3/native
    This package provides low-level bindings to the SQLite3 C API for MoonBit, enabling database operations such as opening/closing databases, executing SQL, preparing and stepping through statements, binding parameters, and reading column values of various types including blob, double, int, and text. Use cases include direct management of SQLite connections and

    Keywords: SQLite3, native bindings, database, sqlite3_open, sqlite3_exec, sqlite3_prepare_v2, sqlite3_step, sqlite3_bind, sqlite3_column, C API, MoonBit, colmugx/sqlite3

chensuiyi/pcap@0.1.1 (29 downloads)
  MoonBit 抓包绑定层：运行时动态加载 wpcap.dll（Npcap）
  Repository: https://gitee.com/chenbimo/moonbit

  chensuiyi/pcap
    chensuiyi/pcap is a MoonBit binding layer for Windows that dynamically loads wpcap.dll (Npcap) at runtime. It provides device enumeration, opening devices, polling packet capture, datalink type queries, error reporting, local IP enumeration, and stdout/stderr output helpers for building packet capture services.

    Keywords: pcap, MoonBit, 抓包, Npcap, wpcap.dll, packet capture, Windows, PacketRaw, Device, Pcap, 网络设备, 收包, next, local_ips, datalink

moonbitstack/moonseal@0.1.2 (25 downloads)
  File and message encryption for MoonBit, for one or several recipients.
  Repository: https://github.com/moonbitstack/moonseal

  moonbitstack/moonseal/stream
    The moonbitstack/moonseal/stream package provides chunked payload sealing and opening for a file-encryption format. Sealer writes ordered chunks with a last-chunk marker, while Opener verifies chunk order, authentication, and truncation, using a payload key derived from the file key and nonce.

    Keywords: moonseal, stream, Sealer, Opener, chunk, payload, payload_key, nonce, tag, file encryption, chunked streaming, authentication, truncation, 分块, 加密

  moonbitstack/moonseal
    moonseal seals data for multiple age v1 recipients so that any one of them can open it, with no key ring or trust model. It provides in-memory and streaming sealing/opening, armored text output, X25519 and scrypt recipient types, and traits for implementing custom recipient types.

    Keywords: moonseal, age v1, file encryption, seal, open, armor, streaming, X25519, scrypt, Recipient, Identity, Source, Sink, 加密, 多人解密

  moonbitstack/moonseal/examples/browser
    Browser example package for moonseal that demonstrates age-style encryption and decryption helpers. It exposes inspect, keygen, seal_passphrase, open_passphrase, seal_to, and open_with for sealing messages to passphrases or age1 keys and opening armored files with age secret keys.

    Keywords: moonseal, browser, age, encryption, decryption, inspect, keygen, seal_passphrase, open_passphrase, seal_to, open_with, X25519, armored, passphrase

chen333w/moon-lite@0.3.0 (18 downloads)
  Pure MoonBit reader for the SQLite 3 file format: pages, b-trees, records and rows, with no C dependency and no FFI.
  Repository: https://github.com/chen333w/moon-lite

  chen333w/moon-lite
    moon-lite is a pure MoonBit reader for the SQLite 3 file format that turns database file bytes into tables, columns and rows without C libraries or FFI. It exposes a Database API for opening bytes, listing tables, and scanning rows with Null, Int, Real, Text and Blob values, and includes a CLI for schema, dump, CSV, SQL and stats output.

    Keywords: moon-lite, MoonBit, SQLite 3, SQLite, database reader, Database::open, tables, rows, Value, rowid, sqlite_master, b-tree…

thy1016/moongard@0.1.2 (22 downloads)
  MoonGard — Guardian 式认证管道框架(access/refresh 双 token 旋转 + 四段分发管线;transport/storage/crypto-free,核心零依赖)
  Repository: https://gitlink.org.cn/thy7/mbt.grd

  thy1016/moongard/adapter/mooncry
    This package provides implementations for cryptographic operations, including AesGcmCipher for AES-256-GCM encryption/decryption and HmacSha256Signer for HMAC-SHA256 signing and verification. It allows for sealing, opening, signing, and verifying data using specific keys and payloads.

    Keywords: AesGcmCipher, HmacSha256Signer, AES-256-GCM, HMAC-SHA256, Cipher, Signer

thy1016/moongrd@0.1.1 (20 downloads)
  MoonGrd — Guardian 式认证管道框架(access/refresh 双 token 旋转 + 四段分发管线;transport/storage/crypto-free,核心零依赖)
  Repository: https://gitlink.org.cn/thy7/mbt.grd

  thy1016/moongrd/adapter/mooncry
    This package provides implementations for encryption and signing using AES-256-GCM cipher and HMAC-SHA256 signature verifier. It includes methods for sealing and opening data with AES-GCM, and signing and verifying data with HMAC-SHA256.

    Keywords: AesGcmCipher, HmacSha256Signer, AES-256-GCM, HMAC-SHA256, Cipher, Signer

JIA2JIA2/lsdb@0.1.0 (8 downloads)
  Append-only event log database built in MoonBit
  Repository: https://github.com/JIA2JIA2/moonbitLog-StructuredDB

  JIA2JIA2/lsdb/src/backend_native
    JIA2JIA2/lsdb/src/backend_native provides native file operations for log management, including directory-level advisory locks via DirLock and a native file-backed append-only log structure via NativeFileLog. It supports opening, reading, truncating, and compressing log segments, alongside mechanisms for managing and recovering consumer cursor positions.

    Keywords: DirLock, NativeFileLog, append-only log, log directory management, consumer cursor, file locking, log recovery, NativeFileLog::open_log_dir

moonbitlang/async@0.22.7 (746340 downloads)
  Asynchronous programming library for MoonBit
  Repository: https://github.com/moonbitlang/async

  moonbitlang/async/fs
    Provides asynchronous file system operations for MoonBit, including opening, reading, writing, seeking, and randomly accessing files; creating, reading, walking, and removing directories; and querying metadata such as file kind, size, timestamps, and permissions. It also offers path resolution, symbolic links, temporary directories, file locking, and a recur

    Keywords: async, file system, 文件系统, File, Directory, Watcher, FsEvent, read_file, write_file, mkdir, readdir, walk, realpath, file lock, file metadata

mizchi/x@0.6.1 (205032 downloads)
  Cross-platform MoonBit compatibility facades with native delegation and accelerated JS implementations for async IO, bytes, regexp, and JSON.
  Repository: https://github.com/mizchi/x

  mizchi/x/fs
    Provides async file system operations: opening/creating files, reading/writing with position control, directory iteration, file metadata, file watching, and symlink management. Includes enums for file kind, lock type, sync mode, and create mode.

    Keywords: async filesystem, file I/O, directory listing, fs, mizchi/x/fs, file metadata, file watching, symlink, MoonBit, async fs

gmlewis/spin-moonbit-sdk@0.55.4 (2311 downloads)
  Experimental Spin SDK for the MoonBit programming language.
  Repository: https://github.com/gmlewis/spin-moonbit-sdk

  gmlewis/spin-moonbit-sdk/interface/fermyon/spin/keyValue
    Provides the Fermyon Spin key-value store interface for MoonBit, exposing the Store resource for opening labeled stores allowed in spin.toml and reading or writing byte values by key. Store supports get, set, delete, exists, get_keys, and drop, with an Error_ enum covering StoreTableFull, NoSuchStore, AccessDenied, and Other failures.

    Keywords: spin, fermyon, keyValue, key-value, Store, get, set, delete, exists, get_keys, open, Error_, NoSuchStore, 键值存储

  gmlewis/spin-moonbit-sdk/interface/fermyon/spin/postgres
    The postgres package provides a Connection type for working with a Postgres database. It supports opening a connection to a Postgres instance by address, executing commands, querying the database with parameters and receiving a RowSet, and dropping a resource handle.

    Keywords: postgres, Postgres database, Connection, open, execute, query, RowSet, ParameterValue, drop, 数据库, 连接

  gmlewis/spin-moonbit-sdk/interface/fermyon/spin/redis
    Provides a MoonBit interface for the Fermyon Spin Redis host API. The Connection type supports opening a Redis connection and performing operations such as get, set, del, incr, set add/remove/members, publish, and arbitrary command execution via execute with RedisParameter and RedisResult, reporting failures through Error_.

    Keywords: spin-moonbit-sdk, fermyon spin, redis, Connection, RedisParameter, RedisResult, execute, get, set, publish, sadd, smembers, Redis 客户端, Redis 接口

  gmlewis/spin-moonbit-sdk/interface/fermyon/spin/sqlite
    This package provides the Spin SQLite interface for MoonBit, exposing a Connection handle for opening named database instances and executing SQL statements with parameters. It includes query result types (QueryResult, RowResult), a Value enum covering Integer, Real, Text, Blob, and Null, and an Error_ enum for database and connection failures.

    Keywords: spin, sqlite, fermyon, moonbit, spin-moonbit-sdk, Connection, QueryResult, RowResult, Value, Error_, SQL, database, 数据库, SQLite 接口

  gmlewis/spin-moonbit-sdk/interface/wasi/filesystem/types
    Provides the WASI filesystem types for the Spin MoonBit SDK, including Descriptor, flags, statistics, directory entries, and ErrorCode. Descriptors expose POSIX-like operations for opening, reading, writing, renaming, linking, unlinking, metadata and timestamp changes, directory listing, and synchronization within a sandboxed base directory.

    Keywords: WASI filesystem, MoonBit, spin-moonbit-sdk, Descriptor, ErrorCode, OpenFlags, PathFlags, DescriptorStat, DirectoryEntryStream, MetadataHashValue, WASI 文件系统, 文件描述符, open_at, read_via_stream, sync

moonbitstack/mooncred@0.6.7 (1935 downloads)
  Credentials for MoonBit: JWT, JWK and X.509.
  Repository: https://github.com/moonbitstack/mooncred

  moonbitstack/mooncred/jwe
    Provides JWE (JSON Web Encryption) support for sealing and opening tokens in the compact serialisation. Public APIs include encrypt and decrypt with caller-supplied algorithms (Alg, Enc), keys (Key, Identity), content-encryption keys, IVs, and RSA-OAEP seed, plus key wrap and unwrap, raising Refused on malformed, unsupported, or key errors.

    Keywords: JWE, JSON Web Encryption, encrypt, decrypt, wrap, unwrap, Alg, Enc, Key, Identity, Refused, compact serialisation, RSA-OAEP-256, key wrapping, 加解密

moonbitstack/moondb@0.2.4 (1710 downloads)
  The standard database-access interface for MoonBit — the driver↔query-layer contract, transliterated from Go's database/sql/driver and Python's DB-API 2.0. ORMs (moonorm) build on it; drivers (moonsqlite / moonpostgres / moonmysql) implement it.
  Repository: https://github.com/moonbitstack/moondb

  moonbitstack/moondb/pool
    The Pool struct provides a fixed-ceiling connection pool for any Driver, reusing expensive database connections instead of opening a new one for every request. It supports connection health checks via pre-ping, connection retirement based on max lifetime, and defines acquire wait budgets.

    Keywords: Pool, Driver, connection pool, acquire, release, max_size, pre_ping, max_lifetime_ms, try_acquire, with_conn

Run `moon add <module>@<version>` to add a dependency.
````

### 7. `moon search "营业时间"`

摘要：无结果。 退出码：0。

````text
No modules found.
````

## GitHub 搜索

按要求检索：

- `opening_hours language:MoonBit` — GitHub 仓库搜索 API 返回 0 个仓库；代码检索关键字 `opening_hours` 与 `MoonBit` 未发现营业时间解析实现。
- `"opening hours" language:MoonBit` — GitHub 仓库搜索 API 返回 0 个仓库；代码检索出现的通用 `opening`/`parser` 结果与 OSM 营业时间无关。

搜索入口：

- [GitHub Code Search: opening_hours language:MoonBit](https://github.com/search?q=opening_hours+language%3AMoonBit&type=code)
- [GitHub Code Search: "opening hours" language:MoonBit](https://github.com/search?q=%22opening+hours%22+language%3AMoonBit&type=code)
- GitHub 仓库检索器同样以 `opening-hours language:MoonBit`、`opening hours language:MoonBit` 查询，均返回空结果。

## 结论

截至 2026-11-02，本次 MoonBit 包索引与 GitHub 检索未发现专门实现 OpenStreetMap `opening_hours` 语法的 MoonBit 包。现有命中属于不相关实现，因此依照查重门槛继续开发原创项目。
