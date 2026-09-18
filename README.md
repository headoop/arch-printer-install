# arch-printer-install

Provisions four CUPS print queues for a **Brother DCP-J774DW** on Arch Linux —
one per recurring kind of print job, so picking the right settings means
picking a queue instead of walking through the print dialog.

## Queues

| Queue                    | Color     | Quality | Duplex | Media  |
| ------------------------ | --------- | ------- | ------ | ------ |
| `Draft`                  | grayscale | fastest | yes    | plain  |
| `GraustufenNormalDuplex` | grayscale | normal  | yes    | plain  |
| `FarbeNormalDuplex`      | color     | normal  | yes    | plain  |
| `FotoBestGlossy`         | color     | best    | no     | glossy |

All four default to A4 and to `printer-error-policy=retry-job`, so a sleeping
Wi-Fi printer does not disable the queue. `GraustufenNormalDuplex` is set as
the system default destination.

## Requirements

- `cups`, with `cups.service` running
- `brother-dcpj774dw` (AUR) — provides the PPD

## Usage

```sh
sudo ./arch-printer-install.sh
```

Each queue is deleted and recreated, so the script is safe to re-run and stays
the single source of truth for these settings. Pending jobs on those queues are
discarded in the process.

## Adapting it

The variables at the top of the script:

- `device` — find yours with `lpinfo -v`
- `model` — find yours with `lpinfo --make-and-model "Brother DCP-J774DW" -l -m`
- `location`, `default_queue`

Per-queue options are the arguments to `create_queue`; anything shared lives in
`common_options`. `lpoptions -p <queue> -l` lists what the PPD accepts, and the
script's header comment carries that list for this model.

## Note on PPDs

`lpadmin` warns that printer drivers are deprecated and will stop working in a
future CUPS release. Driverless IPP is not yet an equivalent here — this
printer advertises only `normal` and `high` print quality, which would cost
both the `Draft` and the `FotoBestGlossy` profile.
